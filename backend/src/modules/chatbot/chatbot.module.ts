import { Module, OnModuleInit } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ChatbotController } from './chatbot.controller';
import { ChatbotService } from './chatbot.service';
import { ChatMessage } from './entities/chat-message.entity';
import { ChatSession } from './entities/chat-session.entity';
import { FaqQuestion } from './entities/faq-question.entity';
import { Tag } from './entities/tag.entity';
import { ChatGateway } from './chat.gateway';
import { FaqService } from './services/faq.service';
import { RagService } from './services/rag.service';

@Module({
  imports: [TypeOrmModule.forFeature([ChatMessage, ChatSession, FaqQuestion, Tag])],
  controllers: [ChatbotController],
  providers: [ChatbotService, ChatGateway, FaqService, RagService],
  exports: [ChatbotService, FaqService],
})
export class ChatbotModule implements OnModuleInit {
  constructor(private faqService: FaqService) {}

  async onModuleInit() {
    try {
      // Temporarily disabled - will enable after ensuring tables exist
      // await this.faqService.seedInitialData();
    } catch (error) {
      console.error('Error seeding FAQ data:', error);
    }
  }
}