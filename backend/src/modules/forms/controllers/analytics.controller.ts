import {
  Controller,
  Get,
  Param,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { AnalyticsService } from '../services/analytics.service';
import { FormAnalyticsResponse, OverallAnalyticsResponse } from '../dto/analytics.dto';

@Controller('api/analytics')
@UseGuards(JwtAuthGuard)
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get('forms/:serviceId')
  async getFormAnalytics(
    @Param('serviceId', ParseIntPipe) serviceId: number
  ): Promise<FormAnalyticsResponse> {
    return await this.analyticsService.getFormAnalytics(serviceId);
  }

  @Get('overview')
  async getOverallAnalytics(): Promise<OverallAnalyticsResponse> {
    return await this.analyticsService.getOverallAnalytics();
  }

  @Get('departments/:departmentId')
  async getDepartmentAnalytics(
    @Param('departmentId', ParseIntPipe) departmentId: number
  ) {
    return await this.analyticsService.getDepartmentAnalytics(departmentId);
  }
}
