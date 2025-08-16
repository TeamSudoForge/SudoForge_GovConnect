import {
  Controller,
  Post,
  Put,
  Get,
  Body,
  Param,
  Req,
  UseGuards,
} from '@nestjs/common';
import { AppointmentService } from './appointments.service';
import { CreateAppointmentDto, UpdateAppointmentDto } from './appointments.dto';
import { JwtAuthGuard } from 'src/common/guards/jwt-auth.guard';

@Controller('appointments')
@UseGuards(JwtAuthGuard)
export class AppointmentController {
  constructor(private readonly appointmentService: AppointmentService) {}

  @Post()
  async create(@Body() dto: CreateAppointmentDto, @Req() req) {
    // userId from JWT/session
    const userId = req.user.id;
    return this.appointmentService.bookAppointment(userId, dto);
  }

  @Put(':ref')
  async update(@Param('ref') ref: string, @Body() dto: UpdateAppointmentDto) {
    return this.appointmentService.updateAppointment(ref, dto);
  }

  @Get(':ref')
  async get(@Param('ref') ref: string) {
    return this.appointmentService.getAppointment(ref);
  }

  @Get('user')
  async getUserAppointments(@Req() req, @Body() body) {
    const userId = req.user.id;
    const { page = 1, pageSize = 10, status } = body || {};
    return this.appointmentService.getUserAppointments(userId, page, pageSize, status);
  }
}
