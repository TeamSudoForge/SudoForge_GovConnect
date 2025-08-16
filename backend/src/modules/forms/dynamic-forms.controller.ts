import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Req } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { DynamicFormsService } from './dynamic-forms.service';
import { FormSeederService } from './seeders/form-seeder.service';
import { CreateDynamicFormDto } from './dto/create-dynamic-form.dto';
import { UpdateDynamicFormDto } from './dto/update-dynamic-form.dto';
import { CreateFormSubmissionDto, UpdateFormSubmissionDto } from './dto/form-submission.dto';

@Controller('dynamic-forms')
// @UseGuards(JwtAuthGuard) // Temporarily disabled for testing
export class DynamicFormsController {
  constructor(
    private readonly dynamicFormsService: DynamicFormsService,
    private readonly formSeederService: FormSeederService,
  ) {}

  @Post()
  async createForm(@Body() createFormDto: CreateDynamicFormDto) {
    return this.dynamicFormsService.createForm(createFormDto);
  }

  @Put(':id')
  async updateForm(@Param('id') id: string, @Body() updateFormDto: UpdateDynamicFormDto) {
    return this.dynamicFormsService.updateForm(id, updateFormDto);
  }

  @Get()
  async getAllForms() {
    return this.dynamicFormsService.getAllForms();
  }

  @Get('field-types')
  async getFieldTypes() {
    return {
      fieldTypes: await this.dynamicFormsService.getFieldTypes(),
    };
  }

  @Get(':id')
  async getFormById(@Param('id') id: string) {
    return this.dynamicFormsService.getFormById(id);
  }

  @Get(':id/config')
  async getFormConfig(@Param('id') id: string) {
    return this.dynamicFormsService.getFormConfigById(id);
  }

  @Get('test/ping')
  async testPing() {
    return { message: 'Dynamic forms API is working', timestamp: new Date() };
  }

  @Get(':id/page/:pageNumber')
  async getFormPage(
    @Param('id') formId: string,
    @Param('pageNumber') pageNumber: number,
  ) {
    return this.dynamicFormsService.getFormsByPage(formId, Number(pageNumber));
  }

  @Delete(':id')
  async deleteForm(@Param('id') id: string) {
    await this.dynamicFormsService.deleteForm(id);
    return { message: 'Form deleted successfully' };
  }

  @Post('submissions')
  async createSubmission(
    @Body() createSubmissionDto: CreateFormSubmissionDto,
    @Req() req: any,
  ) {
    return this.dynamicFormsService.createSubmission(req.user.userId, createSubmissionDto);
  }

  @Put('submissions/:id')
  async updateSubmission(
    @Param('id') id: string,
    @Body() updateSubmissionDto: UpdateFormSubmissionDto,
    @Req() req: any,
  ) {
    return this.dynamicFormsService.updateSubmission(id, req.user.userId, updateSubmissionDto);
  }

  @Get('submissions/my')
  async getUserSubmissions(@Req() req: any) {
    return this.dynamicFormsService.getUserSubmissions(req.user.userId);
  }

  @Get('submissions/:id')
  async getSubmissionById(@Param('id') id: string, @Req() req: any) {
    return this.dynamicFormsService.getSubmissionById(id, req.user.userId);
  }

  @Post('seed-sample')
  async seedSampleForms() {
    await this.formSeederService.seedAllSampleForms();
    return { message: 'Sample forms seeded successfully' };
  }
}
