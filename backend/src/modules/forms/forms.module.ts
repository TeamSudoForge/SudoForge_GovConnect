import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// Entities
import {
  FieldType,
  Field,
  FieldAttribute,
  Department,
  Service,
  FormField as OldFormField,
  FormResponse,
  FormResponseValue,
} from './entities';
import { Official } from './entities/official.entity';

// Dynamic Forms Entities
import {
  Form,
  FormSection,
  FormField,
  FormSubmission,
} from '../../database/entities';

// Services
import { FormsService } from './services/forms.service';
import { FormResponsesService } from './services/form-responses.service';
import { AnalyticsService } from './services/analytics.service';
import { DepartmentsService } from './services/departments.service';
import { ServicesService } from './services/services.service';
import { DynamicFormsService } from './dynamic-forms.service';
import { FormSeederService } from './seeders/form-seeder.service';

// Controllers
import { FormsController } from './controllers/forms.controller';
import { FormResponsesController } from './controllers/form-responses.controller';
import { AnalyticsController } from './controllers/analytics.controller';
import { DepartmentsController } from './controllers/departments.controller';
import { ServicesController } from './controllers/services.controller';
import { DynamicFormsController } from './dynamic-forms.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      FieldType,
      Field,
      FieldAttribute,
      Department,
      Official,
      Service,
      OldFormField,
      FormResponse,
      FormResponseValue,
      // Dynamic Forms entities
      Form,
      FormSection,
      FormField,
      FormSubmission,
    ]),
  ],
  controllers: [
    FormsController,
    FormResponsesController,
    AnalyticsController,
    DepartmentsController,
    ServicesController,
    DynamicFormsController,
  ],
  providers: [
    FormsService,
    FormResponsesService,
    AnalyticsService,
    DepartmentsService,
    ServicesService,
    DynamicFormsService,
    FormSeederService,
  ],
  exports: [
    FormsService,
    FormResponsesService,
    AnalyticsService,
    DepartmentsService,
    ServicesService,
    DynamicFormsService,
    FormSeederService,
  ],
})
export class FormsModule {}
