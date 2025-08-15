import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Form, FormSection, FormField, FormSubmission, FieldType, SubmissionStatus } from '../../database/entities';
import { CreateDynamicFormDto } from './dto/create-dynamic-form.dto';
import { CreateFormSubmissionDto, UpdateFormSubmissionDto } from './dto/form-submission.dto';
import { FieldAttribute } from './entities';

@Injectable()
export class DynamicFormsService {
  constructor(
    @InjectRepository(Form)
    private formRepository: Repository<Form>,
    @InjectRepository(FormSection)
    private formSectionRepository: Repository<FormSection>,
    @InjectRepository(FormField)
    private formFieldRepository: Repository<FormField>,
    @InjectRepository(FormSubmission)
    private formSubmissionRepository: Repository<FormSubmission>,
  ) {}

  async createForm(createFormDto: CreateDynamicFormDto): Promise<Form> {
    const form = this.formRepository.create({
      title: createFormDto.title,
      description: createFormDto.description,
      isActive: createFormDto.isActive,
      version: createFormDto.version,
      metadata: createFormDto.metadata,
    });

    const savedForm = await this.formRepository.save(form);

    // Create sections and fields
    for (const sectionDto of createFormDto.sections) {
      const section = this.formSectionRepository.create({
        title: sectionDto.title,
        description: sectionDto.description,
        pageNumber: sectionDto.pageNumber,
        orderIndex: sectionDto.orderIndex,
        formId: savedForm.id,
      });

      const savedSection = await this.formSectionRepository.save(section);

      // Create fields for this section
      for (const fieldDto of sectionDto.fields) {
        const fieldData: Partial<FormField> = {
          label: fieldDto.label,
          fieldName: fieldDto.fieldName,
          fieldType: fieldDto.fieldType,
          isRequired: fieldDto.isRequired || false,
          placeholder: fieldDto.placeholder || undefined,
          helpText: fieldDto.helpText || undefined,
          orderIndex: fieldDto.orderIndex || 1,
          validationRules: fieldDto.validationRules || undefined,
          options: fieldDto.options || undefined,
          metadata: fieldDto.metadata || undefined,
          sectionId: savedSection.id,
        };
        const field = this.formFieldRepository.create(fieldData);

        await this.formFieldRepository.save(field);
      }
    }

    return this.getFormById(savedForm.id);
  }

  async getAllForms(): Promise<Form[]> {
    return this.formRepository.find({
      relations: ['sections', 'sections.fields'],
      order: {
        createdAt: 'DESC',
        sections: {
          pageNumber: 'ASC',
          orderIndex: 'ASC',
          fields: {
            orderIndex: 'ASC',
          },
        },
      },
    });
  }

  async getFormById(id: string): Promise<Form> {
    const form = await this.formRepository.findOne({
      where: { id },
      relations: ['sections', 'sections.fields'],
      order: {
        sections: {
          pageNumber: 'ASC',
          orderIndex: 'ASC',
          fields: {
            orderIndex: 'ASC',
          },
        },
      },
    });

    if (!form) {
      throw new NotFoundException(`Form with ID ${id} not found`);
    }

    return form;
  }

  async getFormsByPage(formId: string, pageNumber: number): Promise<FormSection[]> {
    const sections = await this.formSectionRepository.find({
      where: { formId, pageNumber },
      relations: ['fields'],
      order: {
        orderIndex: 'ASC',
        fields: {
          orderIndex: 'ASC',
        },
      },
    });

    return sections;
  }

  async createSubmission(userId: string, createSubmissionDto: CreateFormSubmissionDto): Promise<FormSubmission> {
    // Validate form exists
    const form = await this.getFormById(createSubmissionDto.formId);
    if (!form.isActive) {
      throw new BadRequestException('Form is not active');
    }

    // Validate submission data against form structure
    const validationResult = await this.validateSubmissionData(form, createSubmissionDto.submissionData);
    if (!validationResult.isValid) {
      throw new BadRequestException(`Validation failed: ${validationResult.errors.join(', ')}`);
    }

    const submission = this.formSubmissionRepository.create({
      userId,
      formId: createSubmissionDto.formId,
      submissionData: createSubmissionDto.submissionData,
      status: createSubmissionDto.status,
    });

    return this.formSubmissionRepository.save(submission);
  }

  async updateSubmission(
    id: string,
    userId: string,
    updateSubmissionDto: UpdateFormSubmissionDto,
  ): Promise<FormSubmission> {
    const submission = await this.formSubmissionRepository.findOne({
      where: { id, userId },
      relations: ['form'],
    });

    if (!submission) {
      throw new NotFoundException(`Submission with ID ${id} not found`);
    }

    if (updateSubmissionDto.submissionData) {
      // Validate submission data if provided
      const validationResult = await this.validateSubmissionData(submission.form, updateSubmissionDto.submissionData);
      if (!validationResult.isValid) {
        throw new BadRequestException(`Validation failed: ${validationResult.errors.join(', ')}`);
      }
      submission.submissionData = updateSubmissionDto.submissionData;
    }

    if (updateSubmissionDto.status) {
      submission.status = updateSubmissionDto.status;
    }

    if (updateSubmissionDto.reviewNotes) {
      submission.reviewNotes = updateSubmissionDto.reviewNotes;
    }

    return this.formSubmissionRepository.save(submission);
  }

  async getUserSubmissions(userId: string): Promise<FormSubmission[]> {
    return this.formSubmissionRepository.find({
      where: { userId },
      relations: ['form'],
      order: { createdAt: 'DESC' },
    });
  }

  async getSubmissionById(id: string, userId: string): Promise<FormSubmission> {
    const submission = await this.formSubmissionRepository.findOne({
      where: { id, userId },
      relations: ['form', 'form.sections', 'form.sections.fields'],
    });

    if (!submission) {
      throw new NotFoundException(`Submission with ID ${id} not found`);
    }

    return submission;
  }

  private async validateSubmissionData(form: Form, submissionData: any): Promise<{ isValid: boolean; errors: string[] }> {
    const errors: string[] = [];

    // Get all fields from all sections
    const allFields = form.sections.flatMap(section => section.fields);

    // Check required fields
    for (const field of allFields) {
      if (field.isRequired) {
        const fieldValue = submissionData[field.fieldName];
        if (!fieldValue || (Array.isArray(fieldValue) && fieldValue.length === 0)) {
          errors.push(`Field '${field.label}' is required`);
        }
      }

      // Validate field types
      const fieldValue = submissionData[field.fieldName];
      if (fieldValue !== undefined && fieldValue !== null) {
        const typeValidation = this.validateFieldType(field, fieldValue);
        if (!typeValidation.isValid) {
          errors.push(...typeValidation.errors);
        }
      }
    }

    return { isValid: errors.length === 0, errors };
  }

  private validateFieldType(field: FormField, value: any): { isValid: boolean; errors: string[] } {
    const errors: string[] = [];

    switch (field.fieldType) {
      case FieldType.EMAIL:
        if (typeof value !== 'string' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
          errors.push(`Field '${field.label}' must be a valid email address`);
        }
        break;
      case FieldType.PHONE_NUMBER:
        if (typeof value !== 'string' || !/^\+?[\d\s-()]+$/.test(value)) {
          errors.push(`Field '${field.label}' must be a valid phone number`);
        }
        break;
      case FieldType.NUMBER:
        if (typeof value !== 'number' && !(!isNaN(Number(value)))) {
          errors.push(`Field '${field.label}' must be a number`);
        }
        break;
      case FieldType.DATE:
        if (typeof value !== 'string' || isNaN(Date.parse(value))) {
          errors.push(`Field '${field.label}' must be a valid date`);
        }
        break;
      case FieldType.DROPDOWN:
      case FieldType.RADIO_BUTTON:
        if (field.options && Array.isArray(field.options.options)) {
          const validValues = field.options.options.map((opt: any) => opt.value);
          if (!validValues.includes(value)) {
            errors.push(`Field '${field.label}' must be one of: ${validValues.join(', ')}`);
          }
        }
        break;
      case FieldType.CHECKBOX:
        if (!Array.isArray(value)) {
          errors.push(`Field '${field.label}' must be an array`);
        }
        break;
    }

    return { isValid: errors.length === 0, errors };
  }

  async deleteForm(id: string): Promise<void> {
    const form = await this.getFormById(id);
    await this.formRepository.remove(form);
  }

  async getFieldTypes(): Promise<string[]> {
    return Object.values(FieldType);
  }
}
