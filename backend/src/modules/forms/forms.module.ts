import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// Entities
import {
  FieldType,
  Field,
  FieldAttribute,
  Department,
  Service,
  FormField,
  FormResponse,
  FormResponseValue,
} from './entities';

// Services
import { FormsService } from './services/forms.service';
import { FormResponsesService } from './services/form-responses.service';
import { AnalyticsService } from './services/analytics.service';
import { DepartmentsService } from './services/departments.service';

// Controllers
import { FormsController } from './controllers/forms.controller';
import { FormResponsesController } from './controllers/form-responses.controller';
import { AnalyticsController } from './controllers/analytics.controller';
import { DepartmentsController } from './controllers/departments.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      FieldType,
      Field,
      FieldAttribute,
      Department,
      Service,
      FormField,
      FormResponse,
      FormResponseValue,
    ]),
  ],
  controllers: [
    FormsController,
    FormResponsesController,
    AnalyticsController,
    DepartmentsController,
  ],
  providers: [
    FormsService,
    FormResponsesService,
    AnalyticsService,
    DepartmentsService,
  ],
  exports: [
    FormsService,
    FormResponsesService,
    AnalyticsService,
    DepartmentsService,
  ],
})
export class FormsModule {}
