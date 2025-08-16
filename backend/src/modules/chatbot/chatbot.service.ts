import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ChatMessage } from './entities/chat-message.entity';
import { ChatSession } from './entities/chat-session.entity';
import { SendMessageDto } from './dto/send-message.dto';
import { ChatResponseDto } from './dto/chat-response.dto';
import { FaqService } from './services/faq.service';
import { RagService } from './services/rag.service';

@Injectable()
export class ChatbotService {
  private readonly logger = new Logger(ChatbotService.name);

  constructor(
    @InjectRepository(ChatMessage)
    private chatMessageRepository: Repository<ChatMessage>,
    @InjectRepository(ChatSession)
    private chatSessionRepository: Repository<ChatSession>,
    private faqService: FaqService,
    private ragService: RagService,
  ) {}

  async sendMessage(
    sendMessageDto: SendMessageDto,
    userId?: string,
  ): Promise<ChatResponseDto[]> {
    let session: ChatSession | null = null;

    // Get or create session
    if (sendMessageDto.sessionId) {
      session = await this.chatSessionRepository.findOne({
        where: { id: sendMessageDto.sessionId },
      });
    }

    if (!session) {
      session = await this.createSession(userId);
    }

    // Save user message
    const userMessage = await this.saveMessage({
      sessionId: session.id,
      userId,
      message: sendMessageDto.message,
      sender: 'user',
      metadata: sendMessageDto.metadata,
    });

    // Generate bot response
    const botResponseData = await this.generateBotResponse(
      sendMessageDto.message,
      session,
    );

    // Save bot message
    const botMessage = await this.saveMessage({
      sessionId: session.id,
      message: typeof botResponseData === 'string' ? botResponseData : botResponseData.message,
      sender: 'bot',
      metadata: typeof botResponseData === 'string' ? undefined : { quickReplies: botResponseData.quickReplies },
    });

    return [
      this.toResponseDto(userMessage),
      this.toResponseDto(botMessage),
    ];
  }

  async getSessionHistory(sessionId: string): Promise<ChatResponseDto[]> {
    const messages = await this.chatMessageRepository.find({
      where: { sessionId },
      order: { createdAt: 'ASC' },
    });

    return messages.map(msg => this.toResponseDto(msg));
  }

  async getUserSessions(userId: string): Promise<ChatSession[]> {
    return this.chatSessionRepository.find({
      where: { userId },
      order: { updatedAt: 'DESC' },
    });
  }

  private async createSession(userId?: string): Promise<ChatSession> {
    const session = this.chatSessionRepository.create({
      userId,
      title: 'New Chat',
      status: 'active',
      context: { language: null }, // Initialize with language property
    });

    return this.chatSessionRepository.save(session);
  }

  private async saveMessage(data: {
    sessionId: string;
    message: string;
    sender: 'user' | 'bot';
    userId?: string;
    metadata?: Record<string, any>;
  }): Promise<ChatMessage> {
    const message = this.chatMessageRepository.create(data);
    return this.chatMessageRepository.save(message);
  }

  private async generateBotResponse(
    userMessage: string,
    session: ChatSession,
  ): Promise<string | { message: string; quickReplies?: any[] }> {
    const lowerMessage = userMessage.toLowerCase();

    // Check if this is the first message in session (welcome message)
    const messageCount = await this.chatMessageRepository.count({
      where: { sessionId: session.id }
    });
    
    // Show welcome message only for first interaction with empty message
    if (messageCount === 1 && userMessage.trim() === '') { // First user message AND empty
      return {
        message: `Welcome to GovConnect! - Your gateway to seamless government services.\n\nකරුණාකර සංවාදයේ යෙදීමට ඔබට පහසු භාෂාවක් තෝරන්න\nமேலும் தொடர உங்கள் விருப்பிற்குரிய மொழியை தெரிவு செய்யவும்\n\nPlease choose your preferred language to proceed:`,
        quickReplies: [
          { text: '🇬🇧 English', value: '1', type: 'language' },
          { text: '🇱🇰 සිංහල', value: '2', type: 'language' },
          { text: '🇮🇳 தமிழ்', value: '3', type: 'language' }
        ]
      };
    }

    // Language selection - only if language not set AND not a service command
    if (!session.context?.language) {
      // Check if user clicked a service button (bypass language selection)
      const serviceCommands = ['passport', 'driving license', 'birth certificate', 'id card', 'department', 'qr code', 'help', 
                               'lost id card', 'new id card', 'renew id card', 'update id details',
                               'police complaint filed', 'no police complaint', 'why police complaint',
                               'will file complaint', 'documents ready', 'missing documents',
                               'redirect to lost id page', 'no redirect', 'find police station',
                               'missing birth certificate', 'missing address proof', 'need photos', 'need affidavit',
                               'document requirements', 'id office location', 'id office contact'];
      const isServiceCommand = serviceCommands.some(cmd => lowerMessage.includes(cmd));
      
      if (!isServiceCommand) {
        if (lowerMessage === '1' || lowerMessage.includes('english')) {
          session.context = { ...(session.context || {}), language: 'en' };
          await this.chatSessionRepository.save(session);
          return {
            message: "Great! I'll assist you in English. How can I help you today?",
            quickReplies: [
              { text: '🛂 Passport Services', value: 'passport', type: 'action' },
              { text: '🚗 Driving License', value: 'driving license', type: 'action' },
              { text: '👶 Birth Certificate', value: 'birth certificate', type: 'action' },
              { text: '🆔 National ID Card', value: 'id card', type: 'action' },
              { text: '🏢 Government Departments', value: 'department', type: 'action' },
              { text: '📱 QR Queue System', value: 'qr code', type: 'action' },
              { text: '❓ Other Services', value: 'help', type: 'action' }
            ]
          };
        }
        
        if (lowerMessage === '2' || lowerMessage.includes('සිංහල') || lowerMessage.includes('sinhala')) {
          session.context = { ...(session.context || {}), language: 'si' };
          await this.chatSessionRepository.save(session);
          return "හොඳයි! මම ඔබට සිංහල භාෂාවෙන් සහාය වෙමි. මට ඔබට උදව් කළ හැක්කේ:\n• රජයේ සේවා සහ ක්‍රියා පටිපාටි\n• දෙපාර්තමේන්තු ස්ථාන සහ වේලාවන්\n• ලේඛන අවශ්‍යතා\n• QR කේත හරහා පෝලිම් කළමනාකරණය\n• අයදුම්පත් තත්ත්වය පරීක්ෂා කිරීම";
        }
        
        if (lowerMessage === '3' || lowerMessage.includes('தமிழ்') || lowerMessage.includes('tamil')) {
          session.context = { ...(session.context || {}), language: 'ta' };
          await this.chatSessionRepository.save(session);
          return "நல்லது! நான் உங்களுக்கு தமிழில் உதவுவேன். நான் உதவக்கூடியவை:\n• அரசு சேவைகள் மற்றும் நடைமுறைகள்\n• துறை இடங்கள் மற்றும் நேரங்கள்\n• ஆவண தேவைகள்\n• QR குறியீடுகள் மூலம் வரிசை மேலாண்மை\n• விண்ணப்ப நிலை கண்காணிப்பு";
        }
        
        // If no valid language selected, show the welcome message again
        return {
          message: `Welcome to GovConnect! - Your gateway to seamless government services.\n\nකරුණාකර සංවාදයේ යෙදීමට ඔබට පහසු භාෂාවක් තෝරන්න\nமேலும் தொடர உங்கள் விருப்பிற்குரிய மொழியை தெரிவு செய்யவும்\n\nPlease choose your preferred language to proceed:`,
          quickReplies: [
            { text: '🇬🇧 English', value: '1', type: 'language' },
            { text: '🇱🇰 සිංහල', value: '2', type: 'language' },
            { text: '🇮🇳 தமிழ்', value: '3', type: 'language' }
          ]
        };
      }
      
      // If it's a service command, default to English
      session.context = { ...(session.context || {}), language: 'en' };
      await this.chatSessionRepository.save(session);
    }

    // Get language preference for responses
    const language = session.context?.language || 'en';

    // Handle search FAQ request
    if (lowerMessage.includes('search faq')) {
      return {
        message: "What would you like to search for? You can ask me about:\n• Government documents and procedures\n• Office locations and timings\n• Required documents for services\n• Fees and payment methods\n• Application status\n\nJust type your question and I'll search our knowledge base.",
        quickReplies: [
          { text: '🛂 Passport FAQ', value: 'passport faq', type: 'action' },
          { text: '🚗 License FAQ', value: 'license faq', type: 'action' },
          { text: '👶 Birth Certificate FAQ', value: 'birth certificate faq', type: 'action' },
          { text: '🔙 Back to Menu', value: 'help', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('passport')) {
      return {
        message: "For passport services:\n1. Visit the nearest passport office\n2. Bring required documents: Birth certificate, ID proof, Address proof\n3. Fill out the application form\n4. Pay the required fees\n5. Schedule an appointment through our QR system",
        quickReplies: [
          { text: '📍 Find Nearest Office', value: 'passport office location', type: 'action' },
          { text: '📄 Required Documents', value: 'passport documents', type: 'action' },
          { text: '💰 Fee Structure', value: 'passport fees', type: 'action' },
          { text: '📅 Book Appointment', value: 'passport appointment', type: 'action' },
          { text: '🔙 Back to Menu', value: 'help', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('license') || lowerMessage.includes('driving')) {
      return {
        message: "For driving license services:\n1. Learning License: Valid for 6 months\n2. Permanent License: Apply after 30 days of LL\n3. Required documents: Address proof, Age proof, Medical certificate\n4. Online test available for LL\n5. Driving test required for permanent license",
        quickReplies: [
          { text: '📝 Apply for LL', value: 'apply learning license', type: 'action' },
          { text: '🚗 Apply for DL', value: 'apply driving license', type: 'action' },
          { text: '📄 Required Documents', value: 'license documents', type: 'action' },
          { text: '💰 Fee Details', value: 'license fees', type: 'action' },
          { text: '🔙 Back to Menu', value: 'help', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('birth certificate')) {
      return {
        message: "To obtain a birth certificate:\n1. Visit the Municipal Corporation office\n2. Fill out Form-1 (for births within 21 days) or Form-2 (for late registration)\n3. Provide hospital records or affidavit\n4. Pay the applicable fees\n5. Certificate issued within 7-15 working days",
        quickReplies: [
          { text: '📍 Find Office', value: 'municipal office location', type: 'action' },
          { text: '📄 Required Forms', value: 'birth certificate forms', type: 'action' },
          { text: '💻 Apply Online', value: 'birth certificate online', type: 'action' },
          { text: '💰 Fee Structure', value: 'birth certificate fees', type: 'action' },
          { text: '🔙 Back to Menu', value: 'help', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('department') || lowerMessage.includes('office')) {
      return {
        message: "Select a government department:",
        quickReplies: [
          { text: '🏛️ Municipal Corporation', value: 'municipal corporation', type: 'action' },
          { text: '🚗 Transport Department', value: 'transport department', type: 'action' },
          { text: '🛂 Passport Office', value: 'passport office', type: 'action' },
          { text: '💰 Income Tax Department', value: 'income tax', type: 'action' },
          { text: '👮 Police Department', value: 'police department', type: 'action' },
          { text: '🏥 Health Department', value: 'health department', type: 'action' },
          { text: '🔙 Back to Menu', value: 'help', type: 'action' }
        ]
      };
    }

    // Lost ID Card Flow (check specific cases first)
    if (lowerMessage.includes('lost id card')) {
      return {
        message: "Lost ID Card Service\n\nI understand you've lost your ID card. This can be stressful, but don't worry - I'll guide you through the replacement process.\n\nFirst, have you filed a police complaint about your lost ID?",
        quickReplies: [
          { text: '✅ Yes, I have filed', value: 'police complaint filed', type: 'action' },
          { text: '❌ No, not yet', value: 'no police complaint', type: 'action' },
          { text: '❓ Why is it needed?', value: 'why police complaint', type: 'action' },
          { text: '🔙 Back', value: 'id card', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('no police complaint')) {
      return {
        message: "Police Complaint Required\n\nYou'll need to file a police complaint first. Here's what to do:\n\n1. Visit your nearest police station\n2. File an FIR for lost ID card\n3. Get a copy of the FIR (you'll need this)\n\nWould you like to know the nearest police station?",
        quickReplies: [
          { text: '📍 Find Police Station', value: 'find police station', type: 'action' },
          { text: "✅ I'll file it", value: 'will file complaint', type: 'action' },
          { text: '🔙 Back', value: 'lost id card', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('police complaint filed') || lowerMessage.includes('will file complaint')) {
      return {
        message: "Great! Next, you'll need these documents:\n\n✓ Police FIR Copy\n✓ Birth Certificate\n✓ Proof of Address\n✓ 2 Passport-size photos\n✓ Affidavit (if required)\n\nDo you have all these documents ready?",
        quickReplies: [
          { text: '✅ Yes, all ready', value: 'documents ready', type: 'action' },
          { text: '❌ Missing some', value: 'missing documents', type: 'action' },
          { text: '📋 Document Details', value: 'document requirements', type: 'action' },
          { text: '🔙 Back', value: 'lost id card', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('documents ready')) {
      return {
        message: "Perfect! Now let's proceed with the application:\n\n📍 Visit: District Secretariat Office\n⏰ Timing: 9:00 AM - 4:00 PM (Mon-Fri)\n💰 Fee: Rs. 1,000 (Lost ID replacement)\n⏱️ Processing: 14-21 working days\n\nWould you like to be redirected to the Lost ID Card application page?",
        quickReplies: [
          { text: '✅ Yes', value: 'redirect to lost id page', type: 'action' },
          { text: '❌ No', value: 'no redirect', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('redirect to lost id page')) {
      return {
        message: "🔄 Redirecting to Lost ID Card Application Page...\n\n[In a real implementation, this would navigate to the actual service page]\n\nThank you for using GovConnect services!",
        quickReplies: [
          { text: '🏠 Back to Home', value: 'help', type: 'action' },
          { text: '🆔 Other ID Services', value: 'id card', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('no redirect')) {
      return {
        message: "No problem! Is there anything else I can help you with regarding your lost ID card?",
        quickReplies: [
          { text: '📍 Office Locations', value: 'id office location', type: 'action' },
          { text: '📞 Contact Info', value: 'id office contact', type: 'action' },
          { text: '🆔 Other ID Services', value: 'id card', type: 'action' },
          { text: '🏠 Main Menu', value: 'help', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('missing documents')) {
      return {
        message: "Which documents are you missing?",
        quickReplies: [
          { text: '📜 Birth Certificate', value: 'missing birth certificate', type: 'action' },
          { text: '🏠 Address Proof', value: 'missing address proof', type: 'action' },
          { text: '📸 Photos', value: 'need photos', type: 'action' },
          { text: '📄 Affidavit', value: 'need affidavit', type: 'action' },
          { text: '🔙 Back', value: 'police complaint filed', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('why police complaint')) {
      return {
        message: "Why Police Complaint is Required:\n\n1. Legal Protection: Prevents misuse of your lost ID\n2. Official Record: Creates government record of loss\n3. Application Requirement: Mandatory for replacement\n4. Security: Helps track if ID is found/misused\n\nIt's a simple process and takes about 30 minutes.",
        quickReplies: [
          { text: '📍 Find Police Station', value: 'find police station', type: 'action' },
          { text: '✅ Understood', value: 'no police complaint', type: 'action' },
          { text: '🔙 Back', value: 'lost id card', type: 'action' }
        ]
      };
    }

    // National ID Card Services (general menu - check after specific ID cases)
    if (lowerMessage.includes('id card') || lowerMessage.includes('national id') || lowerMessage.includes('nic')) {
      return {
        message: "National ID Card Services:\n\nPlease select the service you need:",
        quickReplies: [
          { text: '🆕 Apply for New ID', value: 'new id card', type: 'action' },
          { text: '🔄 Renew ID Card', value: 'renew id card', type: 'action' },
          { text: '😟 Lost ID Card', value: 'lost id card', type: 'action' },
          { text: '📝 Update Details', value: 'update id details', type: 'action' },
          { text: '📍 Find ID Office', value: 'id office location', type: 'action' },
          { text: '🔙 Back to Menu', value: 'help', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('qr') || lowerMessage.includes('scan')) {
      return {
        message: "Our QR code system helps you:\n1. Skip long queues\n2. Get instant token numbers\n3. Track your position in queue\n4. Receive notifications when it's your turn\n5. Access department-specific services",
        quickReplies: [
          { text: '📱 How to Use', value: 'qr how to use', type: 'action' },
          { text: '🏢 Supported Offices', value: 'qr supported offices', type: 'action' },
          { text: '❓ FAQ', value: 'qr faq', type: 'action' },
          { text: '🔙 Back to Menu', value: 'help', type: 'action' }
        ]
      };
    }

    if (lowerMessage.includes('help') || lowerMessage.includes('support')) {
      return {
        message: "I can help you with government services. Please select a category:",
        quickReplies: [
          { text: '🛂 Passport Services', value: 'passport', type: 'action' },
          { text: '🚗 Driving License', value: 'driving license', type: 'action' },
          { text: '👶 Birth Certificate', value: 'birth certificate', type: 'action' },
          { text: '🆔 National ID Card', value: 'id card', type: 'action' },
          { text: '🏢 Government Departments', value: 'department', type: 'action' },
          { text: '📱 QR Queue System', value: 'qr code', type: 'action' },
          { text: '🔍 Search FAQ', value: 'search faq', type: 'action' }
        ]
      };
    }

    // Use RAG to find relevant content
    // Language is already defined above
    try {
      // First try RAG-based search
      this.logger.log(`Searching with RAG for: "${userMessage}"`);
      const relevantContent = await this.ragService.findRelevantContent(
        userMessage,
        language,
      );
      
      if (relevantContent.length > 0) {
        const ragResponse = this.ragService.generateContextualResponse(
          userMessage,
          relevantContent,
          language,
        );
        
        // Add quick replies for follow-up
        return {
          message: `[AI-Powered Response]\n\n${ragResponse}`,
          quickReplies: [
            { text: '👍 Helpful', value: 'feedback helpful', type: 'action' },
            { text: '👎 Not Helpful', value: 'feedback not helpful', type: 'action' },
            { text: '🔍 Search More', value: 'search faq', type: 'action' },
            { text: '🔙 Main Menu', value: 'help', type: 'action' }
          ]
        };
      }
      
      // Fallback to keyword-based FAQ search
      const keywords = userMessage.split(' ').filter(word => word.length > 3);
      
      if (keywords.length > 0) {
        const faqResults = await this.faqService.findByKeywords(keywords, language);
        
        if (faqResults.length > 0) {
          const topResult = faqResults[0];
          let response = topResult.answer;
          
          // Add related questions if more than one result
          if (faqResults.length > 1) {
            response += '\n\nRelated questions you might find helpful:';
            faqResults.slice(1, 4).forEach((faq, index) => {
              response += `\n${index + 1}. ${faq.question}`;
            });
          }
          
          return response;
        }
      }
    } catch (error) {
      this.logger.error('Error in RAG search:', error);
    }

    // Default response with language consideration
    const defaultResponses = {
      en: "I'm here to help with government services and information. Could you please be more specific about what you need? You can ask about:\n• Passports\n• Driving licenses\n• Birth certificates\n• Government departments\n• QR code queue system\n• Document requirements",
      si: "මම රජයේ සේවා සහ තොරතුරු සම්බන්ධයෙන් උදව් කිරීමට මෙහි සිටිමි. ඔබට අවශ්‍ය දේ ගැන වඩාත් නිශ්චිතව කියන්න පුළුවන්ද? ඔබට අසන්න පුළුවන්:\n• විදේශ ගමන් බලපත්‍ර\n• රියදුරු බලපත්‍ර\n• උප්පැන්න සහතික\n• රජයේ දෙපාර්තමේන්තු\n• QR කේත පෝලිම් පද්ධතිය\n• ලේඛන අවශ්‍යතා",
      ta: "அரசு சேவைகள் மற்றும் தகவல்களுக்கு உதவ நான் இங்கே இருக்கிறேன். உங்களுக்கு என்ன தேவை என்பதை மேலும் குறிப்பிட்டுச் சொல்ல முடியுமா? நீங்கள் கேட்கலாம்:\n• கடவுச்சீட்டுகள்\n• ஓட்டுநர் உரிமங்கள்\n• பிறப்பு சான்றிதழ்கள்\n• அரசு துறைகள்\n• QR குறியீடு வரிசை முறை\n• ஆவண தேவைகள்"
    };
    
    return defaultResponses[language] || defaultResponses.en;
  }

  private toResponseDto(message: ChatMessage): ChatResponseDto {
    const dto: ChatResponseDto = {
      id: message.id,
      sessionId: message.sessionId,
      message: message.message,
      sender: message.sender,
      createdAt: message.createdAt,
      metadata: message.metadata,
    };
    
    // Add quick replies if they exist in metadata
    if (message.metadata?.quickReplies) {
      dto.quickReplies = message.metadata.quickReplies;
    }
    
    return dto;
  }
}