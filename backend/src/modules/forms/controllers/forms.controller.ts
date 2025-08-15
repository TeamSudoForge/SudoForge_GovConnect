import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { FormsService } from '../services/forms.service';
import { CreateFormDto } from '../dto/create-form.dto';
import { Service, FieldType, Field } from '../entities';

@Controller('api/forms')
@UseGuards(JwtAuthGuard)
export class FormsController {
  constructor(private readonly formsService: FormsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async createForm(@Body() createFormDto: CreateFormDto): Promise<Service> {
    return await this.formsService.createForm(createFormDto);
  }

  @Get()
  async getAllForms(): Promise<Service[]> {
    return await this.formsService.getAllForms();
  }

  @Get('field-types')
  async getFieldTypes(): Promise<FieldType[]> {
    return await this.formsService.getAllFieldTypes();
  }

  @Get('fields')
  async getFields(): Promise<Field[]> {
    return await this.formsService.getAllFields();
  }

  @Get(':serviceId')
  async getFormById(
    @Param('serviceId', ParseIntPipe) serviceId: number
  ): Promise<Service> {
    return await this.formsService.getFormById(serviceId);
  }

  @Put(':serviceId')
  async updateForm(
    @Param('serviceId', ParseIntPipe) serviceId: number,
    @Body() updateData: Partial<CreateFormDto>
  ): Promise<Service> {
    return await this.formsService.updateForm(serviceId, updateData);
  }

  @Delete(':serviceId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteForm(
    @Param('serviceId', ParseIntPipe) serviceId: number
  ): Promise<void> {
    await this.formsService.deleteForm(serviceId);
  }
}
