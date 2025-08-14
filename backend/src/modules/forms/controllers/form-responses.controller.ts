import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { FormResponsesService } from '../services/form-responses.service';
import { CreateFormResponseDto, UpdateFormResponseStatusDto } from '../dto/form-response.dto';
import { FormResponse } from '../entities';

@Controller('api/forms')
@UseGuards(JwtAuthGuard)
export class FormResponsesController {
  constructor(private readonly formResponsesService: FormResponsesService) {}

  @Post(':serviceId/responses')
  @HttpCode(HttpStatus.CREATED)
  async submitResponse(
    @Param('serviceId', ParseIntPipe) serviceId: number,
    @Request() req: any,
    @Body() responseData: CreateFormResponseDto
  ): Promise<FormResponse> {
    const userId = req.user.id;
    return await this.formResponsesService.submitResponse(serviceId, userId, responseData);
  }

  @Get(':serviceId/responses')
  async getServiceResponses(
    @Param('serviceId', ParseIntPipe) serviceId: number
  ): Promise<FormResponse[]> {
    return await this.formResponsesService.getResponsesByService(serviceId);
  }

  @Get(':serviceId/responses/:responseId')
  async getResponseById(
    @Param('responseId', ParseIntPipe) responseId: number
  ): Promise<FormResponse> {
    return await this.formResponsesService.getResponseById(responseId);
  }

  @Get('responses/my')
  async getMyResponses(
    @Request() req: any
  ): Promise<FormResponse[]> {
    const userId = req.user.id;
    return await this.formResponsesService.getResponsesByUser(userId);
  }

  @Put(':serviceId/responses/:responseId/status')
  async updateResponseStatus(
    @Param('responseId', ParseIntPipe) responseId: number,
    @Body() statusData: UpdateFormResponseStatusDto
  ): Promise<FormResponse> {
    return await this.formResponsesService.updateResponseStatus(responseId, statusData);
  }

  @Delete(':serviceId/responses/:responseId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteResponse(
    @Param('responseId', ParseIntPipe) responseId: number
  ): Promise<void> {
    await this.formResponsesService.deleteResponse(responseId);
  }
}
