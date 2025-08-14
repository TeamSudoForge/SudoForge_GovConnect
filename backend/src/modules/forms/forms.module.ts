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

// Controllers
import { FormsController } from './controllers/forms.controller';
import { FormResponsesController } from './controllers/form-responses.controller';
import { AnalyticsController } from './controllers/analytics.controller';

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
  ],
  providers: [
    FormsService,
    FormResponsesService,
    AnalyticsService,
  ],
  exports: [
    FormsService,
    FormResponsesService,
    AnalyticsService,
  ],
})
export class FormsModule {}
