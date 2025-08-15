import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Form, FormSection, FormField, FieldType } from '../../../database/entities';

@Injectable()
export class FormSeederService {
  constructor(
    @InjectRepository(Form)
    private formRepository: Repository<Form>,
    @InjectRepository(FormSection)
    private formSectionRepository: Repository<FormSection>,
    @InjectRepository(FormField)
    private formFieldRepository: Repository<FormField>,
  ) {}

  async seedSampleForm(): Promise<Form> {
    // Check if form already exists
    const existingForm = await this.formRepository.findOne({
      where: { id: 'fa79a916-e02d-4e41-888f-ccbd7af664b4' }
    });

    if (existingForm) {
      console.log('Sample form already exists');
      return existingForm;
    }

    // Create the main form
    const form = this.formRepository.create({
      id: 'fa79a916-e02d-4e41-888f-ccbd7af664b4',
      title: 'ID Recovery Application',
      description: 'Apply for official identity document recovery services through our secure digital platform',
      isActive: true,
      version: 1,
      metadata: {
        department: 'Immigration Department',
        announcementUrl: 'https://example.com/announcement'
      }
    });

    const savedForm = await this.formRepository.save(form);

    // Create sections and fields
    await this.createOverviewSection(savedForm.id);
    await this.createApplicationDetailsSection(savedForm.id);
    await this.createDocumentUploadSection(savedForm.id);
    await this.createAdditionalInfoSection(savedForm.id);

    console.log('Sample form seeded successfully');
    return savedForm;
  }

  private async createOverviewSection(formId: string): Promise<void> {
    const section = this.formSectionRepository.create({
      id: 'overview-section',
      title: 'Auto-filled Data Requirements',
      description: 'Complete the following forms to auto-populate your application data',
      pageNumber: 1,
      orderIndex: 1,
      formId: formId
    });

    const savedSection = await this.formSectionRepository.save(section);

    // Create dependency form fields
    const fields = [
      {
        id: 'profile-form-dep',
        label: 'Personal Profile Information',
        fieldName: 'personal_profile_completed',
        fieldType: FieldType.DEPENDENCY_FORM,
        isRequired: true,
        helpText: 'Complete your basic personal information including name, date of birth, and contact details. This information will be used to verify your identity.',
        orderIndex: 1,
        metadata: {
          formUrl: 'profile-setup-form-001',
          isFilled: false
        }
      },
      {
        id: 'address-form-dep',
        label: 'Address Verification',
        fieldName: 'address_verification_completed',
        fieldType: FieldType.DEPENDENCY_FORM,
        isRequired: true,
        helpText: 'Provide and verify your current residential address. This helps us ensure accurate document delivery.',
        orderIndex: 2,
        metadata: {
          formUrl: 'address-verification-form-002',
          isFilled: false
        }
      },
      {
        id: 'emergency-contact-dep',
        label: 'Emergency Contact Information',
        fieldName: 'emergency_contact_completed',
        fieldType: FieldType.DEPENDENCY_FORM,
        isRequired: false,
        helpText: 'Provide emergency contact details for security purposes and in case we need to verify your identity.',
        orderIndex: 3,
        metadata: {
          formUrl: 'emergency-contact-form-003',
          isFilled: true
        }
      }
    ];

    for (const fieldData of fields) {
      const field = this.formFieldRepository.create({
        ...fieldData,
        sectionId: savedSection.id
      });
      await this.formFieldRepository.save(field);
    }
  }

  private async createApplicationDetailsSection(formId: string): Promise<void> {
    const section = this.formSectionRepository.create({
      id: '2fd6cc13-4b2b-4b51-b7df-81f89fe6af69',
      title: 'Application Details',
      description: 'Basic information about your ID recovery request',
      pageNumber: 2,
      orderIndex: 2,
      formId: formId
    });

    const savedSection = await this.formSectionRepository.save(section);

    const fields = [
      {
        id: 'reason-for-recovery',
        label: 'Reason for ID Recovery',
        fieldName: 'recovery_reason',
        fieldType: FieldType.DROPDOWN,
        isRequired: true,
        placeholder: 'Select reason',
        helpText: 'Please specify why you need to recover your ID',
        orderIndex: 1,
        options: {
          options: [
            { value: 'lost', label: 'Lost' },
            { value: 'stolen', label: 'Stolen' },
            { value: 'damaged', label: 'Damaged' },
            { value: 'expired', label: 'Expired' }
          ]
        }
      },
      {
        id: 'incident-date',
        label: 'Date of Incident',
        fieldName: 'incident_date',
        fieldType: FieldType.DATE,
        isRequired: false,
        helpText: 'When did you realize your ID was lost/stolen/damaged?',
        orderIndex: 2
      }
    ];

    for (const fieldData of fields) {
      const field = this.formFieldRepository.create({
        ...fieldData,
        sectionId: savedSection.id
      });
      await this.formFieldRepository.save(field);
    }
  }

  private async createDocumentUploadSection(formId: string): Promise<void> {
    const section = this.formSectionRepository.create({
      id: 'document-upload-section',
      title: 'Document Upload',
      description: 'Upload required supporting documents',
      pageNumber: 3,
      orderIndex: 3,
      formId: formId
    });

    const savedSection = await this.formSectionRepository.save(section);

    const fields = [
      {
        id: 'police-report',
        label: 'Police Report',
        fieldName: 'police_report',
        fieldType: FieldType.DOCUMENT_UPLOAD,
        isRequired: true,
        helpText: 'Upload the police report if your ID was stolen',
        orderIndex: 1,
        metadata: {
          acceptedTypes: ['.pdf', '.jpg', '.png'],
          maxSize: '5MB'
        }
      },
      {
        id: 'proof-of-identity',
        label: 'Proof of Identity',
        fieldName: 'proof_of_identity',
        fieldType: FieldType.DOCUMENT_UPLOAD,
        isRequired: true,
        helpText: 'Upload any alternative identity documents',
        orderIndex: 2,
        metadata: {
          acceptedTypes: ['.pdf', '.jpg', '.png'],
          maxSize: '5MB'
        }
      }
    ];

    for (const fieldData of fields) {
      const field = this.formFieldRepository.create({
        ...fieldData,
        sectionId: savedSection.id
      });
      await this.formFieldRepository.save(field);
    }
  }

  private async createAdditionalInfoSection(formId: string): Promise<void> {
    const section = this.formSectionRepository.create({
      id: 'additional-info-section',
      title: 'Additional Information',
      description: 'Provide additional details for your application',
      pageNumber: 4,
      orderIndex: 3,
      formId: formId
    });

    const savedSection = await this.formSectionRepository.save(section);

    const fields = [
      {
        id: 'additional-details',
        label: 'Additional Details',
        fieldName: 'additional_details',
        fieldType: FieldType.TEXTAREA,
        isRequired: false,
        placeholder: 'Provide any additional information...',
        helpText: 'Any other relevant information about your ID recovery request',
        orderIndex: 1,
        metadata: {
          maxLines: 4
        }
      },
      {
        id: 'emergency-contact-name',
        label: 'Emergency Contact Name',
        fieldName: 'emergency_contact_name',
        fieldType: FieldType.TEXT,
        isRequired: false,
        placeholder: 'Enter emergency contact name',
        helpText: 'Name of person to contact in case of emergency',
        orderIndex: 2
      },
      {
        id: 'emergency-contact-phone',
        label: 'Emergency Contact Phone',
        fieldName: 'emergency_contact_phone',
        fieldType: FieldType.PHONE_NUMBER,
        isRequired: false,
        placeholder: 'Enter phone number',
        helpText: 'Phone number of emergency contact',
        orderIndex: 3
      }
    ];

    for (const fieldData of fields) {
      const field = this.formFieldRepository.create({
        ...fieldData,
        sectionId: savedSection.id
      });
      await this.formFieldRepository.save(field);
    }
  }

  async seedAllSampleForms(): Promise<void> {
    await this.seedSampleForm();
    // Add more sample forms here as needed
  }
}
