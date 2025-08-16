import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  UseGuards,
  Request,
  Query,
} from '@nestjs/common';
import { ChatbotService } from './chatbot.service';
import { SendMessageDto } from './dto/send-message.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { FaqService } from './services/faq.service';

@Controller('chatbot')
export class ChatbotController {
  constructor(
    private readonly chatbotService: ChatbotService,
    private readonly faqService: FaqService,
  ) {}

  @Post('message')
  async sendMessage(
    @Body() sendMessageDto: SendMessageDto,
    @Request() req: any,
  ) {
    const userId = req.user?.id;
    return this.chatbotService.sendMessage(sendMessageDto, userId);
  }

  @UseGuards(JwtAuthGuard)
  @Post('message/authenticated')
  async sendAuthenticatedMessage(
    @Body() sendMessageDto: SendMessageDto,
    @Request() req: any,
  ) {
    return this.chatbotService.sendMessage(sendMessageDto, req.user.id);
  }

  @Get('session/:sessionId/history')
  async getSessionHistory(@Param('sessionId') sessionId: string) {
    return this.chatbotService.getSessionHistory(sessionId);
  }

  @UseGuards(JwtAuthGuard)
  @Get('sessions')
  async getUserSessions(@Request() req: any) {
    return this.chatbotService.getUserSessions(req.user.id);
  }

  @Get('tags')
  async getTags(@Query('lang') language: string = 'en') {
    return this.faqService.getAllTags(language);
  }

  @Get('faq/tags/:tagIds')
  async getFaqByTags(
    @Param('tagIds') tagIds: string,
    @Query('lang') language: string = 'en',
  ) {
    const tagIdArray = tagIds.split(',');
    return this.faqService.findByTags(tagIdArray, language);
  }

  @Get('faq/popular')
  async getPopularFaqs(
    @Query('limit') limit: string = '5',
    @Query('lang') language: string = 'en',
  ) {
    return this.faqService.getPopularQuestions(parseInt(limit), language);
  }

  @Get('faq/search')
  async searchFaq(
    @Query('q') query: string,
    @Query('lang') language: string = 'en',
  ) {
    const keywords = query.split(' ').filter(word => word.length > 2);
    return this.faqService.findByKeywords(keywords, language);
  }
}