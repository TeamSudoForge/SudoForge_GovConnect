import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  ParseIntPipe,
  UseGuards,
  Request,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';

import { Service } from '../entities/service.entity';
import { ServicesService } from '../services/services.service';
import { CreateServiceDto } from '../dto/create-form.dto';
import { UpdateServiceDto } from '../dto/service.dto';

@Controller('api/services')
@UseGuards(JwtAuthGuard)
export class ServicesController {
  constructor(private readonly servicesService: ServicesService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createService(
    @Request() req: any,
    @Body() createServiceDto: CreateServiceDto
  ): Promise<Service> {
    // Extract department_id from JWT token
    const departmentId = req.user.department_id;
    return await this.servicesService.createService(departmentId, createServiceDto);
  }

  @Get()
  async getDepartmentServices(
    @Request() req: any,
    @Query('active') active?: string
  ): Promise<Service[]> {
    const departmentId = req.user.department_id;
    const isActive = active !== undefined ? active === 'true' : undefined;
    return await this.servicesService.getServicesByDepartment(departmentId, isActive);
  }

  @Get(':serviceId')
  async getServiceById(
    @Request() req: any,
    @Param('serviceId', ParseIntPipe) serviceId: number
  ): Promise<Service> {
    const departmentId = req.user.department_id;
    return await this.servicesService.getServiceById(serviceId, departmentId);
  }

  @Put(':serviceId')
  async updateService(
    @Request() req: any,
    @Param('serviceId', ParseIntPipe) serviceId: number,
    @Body() updateServiceDto: UpdateServiceDto
  ): Promise<Service> {
    const departmentId = req.user.department_id;
    return await this.servicesService.updateService(serviceId, departmentId, updateServiceDto);
  }

  @Delete(':serviceId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteService(
    @Request() req: any,
    @Param('serviceId', ParseIntPipe) serviceId: number
  ): Promise<void> {
    const departmentId = req.user.department_id;
    await this.servicesService.deleteService(serviceId, departmentId);
  }

  @Put(':serviceId/toggle-status')
  async toggleServiceStatus(
    @Request() req: any,
    @Param('serviceId', ParseIntPipe) serviceId: number
  ): Promise<Service> {
    const departmentId = req.user.department_id;
    return await this.servicesService.toggleServiceStatus(serviceId, departmentId);
  }
}
