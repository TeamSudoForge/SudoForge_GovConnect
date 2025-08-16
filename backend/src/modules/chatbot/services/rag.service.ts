import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FaqQuestion } from '../entities/faq-question.entity';

interface VectorSearchResult {
  question: FaqQuestion;
  score: number;
}

@Injectable()
export class RagService {
  private knowledgeBase: Map<string, string[]> = new Map();

  constructor(
    @InjectRepository(FaqQuestion)
    private faqRepository: Repository<FaqQuestion>,
  ) {
    this.initializeKnowledgeBase();
  }

  private initializeKnowledgeBase() {
    // Government services knowledge base
    this.knowledgeBase.set('passport', [
      'travel', 'document', 'international', 'visa', 'abroad', 'foreign',
      'embassy', 'consulate', 'application', 'renewal', 'expired',
    ]);
    
    this.knowledgeBase.set('license', [
      'driving', 'vehicle', 'car', 'motorcycle', 'test', 'RTO',
      'transport', 'learner', 'permanent', 'renewal', 'traffic',
    ]);
    
    this.knowledgeBase.set('birth', [
      'certificate', 'baby', 'newborn', 'registration', 'municipal',
      'corporation', 'hospital', 'proof', 'age', 'document',
    ]);
    
    this.knowledgeBase.set('queue', [
      'qr', 'code', 'scan', 'token', 'wait', 'time', 'skip',
      'appointment', 'schedule', 'notification', 'turn',
    ]);
    
    this.knowledgeBase.set('department', [
      'office', 'government', 'ministry', 'location', 'timing',
      'hours', 'contact', 'address', 'service', 'counter',
    ]);
  }

  async findRelevantContent(
    query: string,
    language: string = 'en',
    threshold: number = 0.3,
  ): Promise<VectorSearchResult[]> {
    const queryLower = query.toLowerCase();
    const queryWords = queryLower.split(' ').filter(w => w.length > 2);
    
    // Calculate relevance scores for each knowledge domain
    const domainScores: Map<string, number> = new Map();
    
    for (const [domain, keywords] of this.knowledgeBase) {
      let score = 0;
      
      // Direct domain match
      if (queryLower.includes(domain)) {
        score += 0.5;
      }
      
      // Keyword matches
      for (const keyword of keywords) {
        if (queryLower.includes(keyword)) {
          score += 0.3;
        }
      }
      
      // Word overlap
      for (const word of queryWords) {
        if (keywords.some(kw => kw.includes(word) || word.includes(kw))) {
          score += 0.2;
        }
      }
      
      if (score > threshold) {
        domainScores.set(domain, score);
      }
    }
    
    // Get FAQs from relevant domains
    const relevantFaqs: VectorSearchResult[] = [];
    
    if (domainScores.size > 0) {
      const allFaqs = await this.faqRepository.find({
        where: { isActive: true },
        relations: ['tags'],
      });
      
      for (const faq of allFaqs) {
        let faqScore = 0;
        const questionField = language === 'si' ? faq.questionSi 
          : language === 'ta' ? faq.questionTa 
          : faq.questionEn;
        
        // Check FAQ content against query
        const faqLower = questionField.toLowerCase();
        
        // Exact phrase match
        if (faqLower.includes(queryLower)) {
          faqScore += 1.0;
        }
        
        // Word matches
        for (const word of queryWords) {
          if (faqLower.includes(word)) {
            faqScore += 0.3;
          }
        }
        
        // Domain relevance
        for (const [domain, score] of domainScores) {
          if (faq.category === domain || faqLower.includes(domain)) {
            faqScore += score * 0.5;
          }
        }
        
        if (faqScore > threshold) {
          relevantFaqs.push({ question: faq, score: faqScore });
        }
      }
    }
    
    // Sort by score
    return relevantFaqs.sort((a, b) => b.score - a.score).slice(0, 5);
  }

  generateContextualResponse(
    query: string,
    relevantContent: VectorSearchResult[],
    language: string = 'en',
  ): string {
    if (relevantContent.length === 0) {
      return this.getNoResultsMessage(language);
    }
    
    const topResult = relevantContent[0];
    const answerField = language === 'si' ? 'answerSi' 
      : language === 'ta' ? 'answerTa' 
      : 'answerEn';
    
    let response = topResult.question[answerField];
    
    // Add additional context if score is not very high
    if (topResult.score < 0.8 && relevantContent.length > 1) {
      const additionalInfo = this.getAdditionalInfo(language);
      response += `\n\n${additionalInfo}`;
      
      relevantContent.slice(1, 3).forEach((result, index) => {
        const questionField = language === 'si' ? 'questionSi' 
          : language === 'ta' ? 'questionTa' 
          : 'questionEn';
        response += `\n${index + 1}. ${result.question[questionField]}`;
      });
    }
    
    return response;
  }

  private getNoResultsMessage(language: string): string {
    const messages = {
      en: "I couldn't find specific information about your query. Please try rephrasing your question or contact our support team for assistance.",
      si: "ඔබගේ ප්‍රශ්නයට අදාළ නිශ්චිත තොරතුරු සොයා ගැනීමට නොහැකි විය. කරුණාකර ඔබේ ප්‍රශ්නය වෙනත් ආකාරයකින් ඇසීමට උත්සාහ කරන්න හෝ සහාය සඳහා අපගේ සහාය කණ්ඩායම අමතන්න.",
      ta: "உங்கள் கேள்விக்கான குறிப்பிட்ட தகவலை என்னால் கண்டுபிடிக்க முடியவில்லை. உங்கள் கேள்வியை மீண்டும் எழுத முயற்சிக்கவும் அல்லது உதவிக்கு எங்கள் ஆதரவு குழுவை தொடர்பு கொள்ளவும்.",
    };
    return messages[language] || messages.en;
  }

  private getAdditionalInfo(language: string): string {
    const messages = {
      en: "You might also find these related topics helpful:",
      si: "මෙම අදාළ මාතෘකා ද ඔබට ප්‍රයෝජනවත් විය හැක:",
      ta: "இந்த தொடர்புடைய தலைப்புகளும் உங்களுக்கு உதவியாக இருக்கலாம்:",
    };
    return messages[language] || messages.en;
  }
}