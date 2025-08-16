import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// Only keep Department entity for authentication
import { Department } from './entities';

// Dynamic Forms Entities (the main system)
import {
  Form,
  FormSection,
  FormField,
  FormSubmission,
} from '../../database/entities';

// Services - keep only needed ones
import { DepartmentsService } from './services/departments.service';
import { DynamicFormsService } from './dynamic-forms.service';
import { FormSeederService } from './seeders/form-seeder.service';

// Controllers - keep only needed ones
import { DepartmentsController } from './controllers/departments.controller';
import { DynamicFormsController } from './dynamic-forms.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Department,
      // Dynamic Forms entities
      Form,
      FormSection,
      FormField,
      FormSubmission,
    ]),
  ],
  controllers: [
    DepartmentsController,
    DynamicFormsController,
  ],
  providers: [
    DepartmentsService,
    DynamicFormsService,
    FormSeederService,
  ],
  exports: [
    DepartmentsService,
    DynamicFormsService,
    FormSeederService,
  ],
})
export class FormsModule {}
