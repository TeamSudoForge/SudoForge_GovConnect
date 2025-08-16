import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { FaqQuestion } from '../entities/faq-question.entity';
import { Tag } from '../entities/tag.entity';

@Injectable()
export class FaqService {
  constructor(
    @InjectRepository(FaqQuestion)
    private faqRepository: Repository<FaqQuestion>,
    @InjectRepository(Tag)
    private tagRepository: Repository<Tag>,
  ) {}

  async findByTags(tagIds: string[], language: string = 'en'): Promise<any[]> {
    const questions = await this.faqRepository
      .createQueryBuilder('faq')
      .leftJoinAndSelect('faq.tags', 'tag')
      .where('tag.id IN (:...tagIds)', { tagIds })
      .andWhere('faq.isActive = :isActive', { isActive: true })
      .orderBy('faq.order', 'ASC')
      .addOrderBy('faq.viewCount', 'DESC')
      .getMany();

    return this.formatQuestions(questions, language);
  }

  async findByKeywords(keywords: string[], language: string = 'en'): Promise<any[]> {
    const queryBuilder = this.faqRepository
      .createQueryBuilder('faq')
      .leftJoinAndSelect('faq.tags', 'tags')
      .where('faq.isActive = :isActive', { isActive: true });

    // Search in questions based on language
    const questionField = `question${language.charAt(0).toUpperCase() + language.slice(1)}`;
    keywords.forEach((keyword, index) => {
      queryBuilder.orWhere(`LOWER(faq.${questionField}) LIKE :keyword${index}`, {
        [`keyword${index}`]: `%${keyword.toLowerCase()}%`,
      });
    });

    const questions = await queryBuilder
      .orderBy('faq.viewCount', 'DESC')
      .limit(10)
      .getMany();

    // Increment view count
    if (questions.length > 0) {
      await this.faqRepository
        .createQueryBuilder()
        .update(FaqQuestion)
        .set({ viewCount: () => 'viewCount + 1' })
        .whereInIds(questions.map(q => q.id))
        .execute();
    }

    return this.formatQuestions(questions, language);
  }

  async getAllTags(language: string = 'en'): Promise<any[]> {
    const tags = await this.tagRepository.find({
      where: { isActive: true },
      order: { category: 'ASC', order: 'ASC' },
    });

    return tags.map(tag => ({
      id: tag.id,
      name: this.getLocalizedField(tag, 'name', language),
      category: tag.category,
      icon: tag.icon,
    }));
  }

  async getPopularQuestions(limit: number = 5, language: string = 'en'): Promise<any[]> {
    const questions = await this.faqRepository.find({
      where: { isActive: true },
      order: { viewCount: 'DESC' },
      take: limit,
      relations: ['tags'],
    });

    return this.formatQuestions(questions, language);
  }

  private formatQuestions(questions: FaqQuestion[], language: string): any[] {
    return questions.map(q => ({
      id: q.id,
      question: this.getLocalizedField(q, 'question', language),
      answer: this.getLocalizedField(q, 'answer', language),
      category: q.category,
      tags: q.tags?.map(tag => ({
        id: tag.id,
        name: this.getLocalizedField(tag, 'name', language),
      })) || [],
    }));
  }

  private getLocalizedField(entity: any, field: string, language: string): string {
    const langSuffix = language.charAt(0).toUpperCase() + language.slice(1);
    return entity[`${field}${langSuffix}`] || entity[`${field}En`];
  }

  // Seed initial data
  async seedInitialData(): Promise<void> {
    const existingCount = await this.tagRepository.count();
    if (existingCount > 0) return;

    // Create tags
    const tags = await this.tagRepository.save([
      {
        name: 'passport',
        nameEn: 'Passport',
        nameSi: 'විදේශ ගමන් බලපත්‍රය',
        nameTa: 'கடவுச்சீட்டு',
        category: 'documents',
        icon: '🛂',
        order: 1,
      },
      {
        name: 'driving-license',
        nameEn: 'Driving License',
        nameSi: 'රියදුරු බලපත්‍රය',
        nameTa: 'ஓட்டுநர் உரிமம்',
        category: 'documents',
        icon: '🚗',
        order: 2,
      },
      {
        name: 'birth-certificate',
        nameEn: 'Birth Certificate',
        nameSi: 'උප්පැන්න සහතිකය',
        nameTa: 'பிறப்பு சான்றிதழ்',
        category: 'documents',
        icon: '👶',
        order: 3,
      },
      {
        name: 'queue-system',
        nameEn: 'Queue System',
        nameSi: 'පෝලිම් පද්ධතිය',
        nameTa: 'வரிசை முறை',
        category: 'services',
        icon: '📱',
        order: 4,
      },
    ]);

    // Create FAQ questions
    const passportTag = tags.find(t => t.name === 'passport');
    const queueTag = tags.find(t => t.name === 'queue-system');

    await this.faqRepository.save([
      {
        questionEn: 'How do I apply for a new passport?',
        questionSi: 'නව විදේශ ගමන් බලපත්‍රයක් සඳහා අයදුම් කරන්නේ කෙසේද?',
        questionTa: 'புதிய கடவுச்சீட்டுக்கு எப்படி விண்ணப்பிப்பது?',
        answerEn: 'To apply for a new passport: 1) Visit the nearest passport office or apply online, 2) Submit required documents (Birth Certificate, NIC, proof of address), 3) Pay the applicable fees, 4) Attend biometric capture appointment, 5) Collect passport after processing (usually 10-14 working days).',
        answerSi: 'නව විදේශ ගමන් බලපත්‍රයක් සඳහා: 1) ළඟම විදේශ ගමන් බලපත්‍ර කාර්යාලයට පැමිණෙන්න හෝ මාර්ගගතව අයදුම් කරන්න, 2) අවශ්‍ය ලේඛන ඉදිරිපත් කරන්න, 3) අදාළ ගාස්තු ගෙවන්න, 4) biometric දත්ත ලබා දීම සඳහා පැමිණෙන්න, 5) සැකසීමෙන් පසු බලපත්‍රය ලබා ගන්න.',
        answerTa: 'புதிய கடவுச்சீட்டுக்கு விண்ணப்பிக்க: 1) அருகிலுள்ள கடவுச்சீட்டு அலுவலகத்திற்கு செல்லவும், 2) தேவையான ஆவணங்களை சமர்ப்பிக்கவும், 3) கட்டணம் செலுத்தவும், 4) பயோமெட்ரிக் சந்திப்புக்கு வரவும், 5) செயலாக்கத்திற்குப் பிறகு கடவுச்சீட்டை பெறவும்.',
        category: 'documents',
        tags: passportTag ? [passportTag] : [],
        order: 1,
      },
      {
        questionEn: 'How does the QR code queue system work?',
        questionSi: 'QR කේත පෝලිම් පද්ධතිය ක්‍රියා කරන්නේ කෙසේද?',
        questionTa: 'QR குறியீடு வரிசை முறை எப்படி வேலை செய்கிறது?',
        answerEn: 'The QR code queue system works as follows: 1) Scan the QR code displayed at the government office entrance, 2) Select your required service from the list, 3) Receive a digital token number, 4) Track your position in real-time through the app, 5) Get notifications when your turn approaches, 6) Show your token at the counter when called.',
        answerSi: 'QR කේත පෝලිම් පද්ධතිය: 1) කාර්යාල පිවිසුමේ ඇති QR කේතය scan කරන්න, 2) ඔබට අවශ්‍ය සේවාව තෝරන්න, 3) ඩිජිටල් ටෝකන් අංකයක් ලබා ගන්න, 4) යෙදුම හරහා ඔබේ ස්ථානය නිරීක්ෂණය කරන්න, 5) ඔබේ වාරය ළඟා වන විට දැනුම් දීමක් ලැබේ.',
        answerTa: 'QR குறியீடு வரிசை முறை: 1) அலுவலக நுழைவாயிலில் உள்ள QR குறியீட்டை ஸ்கேன் செய்யவும், 2) தேவையான சேவையைத் தேர்ந்தெடுக்கவும், 3) டிஜிட்டல் டோக்கன் எண்ணைப் பெறவும், 4) ஆப் மூலம் உங்கள் நிலையைக் கண்காணிக்கவும், 5) உங்கள் முறை நெருங்கும்போது அறிவிப்பு பெறவும்.',
        category: 'services',
        tags: queueTag ? [queueTag] : [],
        order: 2,
      },
    ]);
  }
}