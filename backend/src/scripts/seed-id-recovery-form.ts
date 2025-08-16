import { DataSource } from 'typeorm';
import { Form } from '../database/entities/form.entity';
import { FormSection } from '../database/entities/form-section.entity';
import { FormField } from '../database/entities/form-field.entity';
import typeOrmConfig from '../config/typeorm.config';
import { Department } from '../modules/forms/entities/department.entity';

async function seedIdRecoveryForm() {
  console.log('🌱 Seeding ID Recovery Form...');
  
  const AppDataSource = new DataSource(typeOrmConfig as any);
  await AppDataSource.initialize();

  const formRepository = AppDataSource.getRepository(Form);
  const sectionRepository = AppDataSource.getRepository(FormSection);
  const fieldRepository = AppDataSource.getRepository(FormField);
  const departmentRepository = AppDataSource.getRepository(Department);

  // Get or create a department first
  let department = await departmentRepository.findOne({ where: { name: 'Immigration Department' } });
  if (!department) {
    department = departmentRepository.create({
      name: 'Immigration Department',
      description: 'Handles immigration and identity services',
      contactEmail: 'immigration@gov.connect',
      contactPhone: '+94789076543'
    });
    await departmentRepository.save(department);
  }

  // Create the main form
  const idRecoveryForm = formRepository.create({
    id: 'fa79a916-e02d-4e41-888f-ccbd7af664b4',
    title: 'ID Recovery Application',
    description: 'Apply for official identity document recovery services through our secure digital platform',
    isActive: true,
    version: 1,
    metadata: {
      department: 'Immigration Department',
      estimatedTime: '15-20 minutes',
      requiredDocuments: ['Birth Certificate', 'Proof of Address', 'Police Report']
    }
  });

  await formRepository.save(idRecoveryForm);
  console.log('✅ Created main form');

  // Section 1: Personal Information
  const personalInfoSection = sectionRepository.create({
    id: '2fd6cc13-4b2b-4b51-b7df-81f89fe6af69',
    title: 'Personal Information',
    description: 'Please provide your personal details as they appear on official documents',
    pageNumber: 1,
    orderIndex: 1,
    form: idRecoveryForm
  });

  await sectionRepository.save(personalInfoSection);

  // Personal Information Fields
  const personalFields = [
    {
      id: '250acf84-e85d-41d5-a7a3-4ace92d24d7b',
      label: 'Full Name',
      fieldName: 'full_name',
      fieldType: 'text',
      isRequired: true,
      placeholder: 'Enter your full name as it appears on documents',
      helpText: 'Include all names as shown on your birth certificate',
      orderIndex: 1,
      validationRules: {
        minLength: 2,
        maxLength: 100,
        allowNumeric: false,
        allowSpecialChars: false
      }
    },
    {
      id: '758c78a8-6cc5-4730-bd3f-df88e792689d',
      label: 'Email Address',
      fieldName: 'email',
      fieldType: 'email',
      isRequired: true,
      placeholder: 'your@email.com',
      helpText: 'We will send updates to this email address',
      orderIndex: 2,
      validationRules: {
        emailFormat: true
      }
    },
    {
      id: '9a1b2c3d-4e5f-6789-abcd-ef1234567890',
      label: 'Mobile Number',
      fieldName: 'mobile_number',
      fieldType: 'text',
      isRequired: true,
      placeholder: '+1 (555) 123-4567',
      helpText: 'Include country code',
      orderIndex: 3,
      validationRules: {
        phoneFormat: true,
        minLength: 10,
        maxLength: 15
      }
    },
    {
      id: '1a2b3c4d-5e6f-7890-bcde-f12345678901',
      label: 'Date of Birth',
      fieldName: 'date_of_birth',
      fieldType: 'date',
      isRequired: true,
      placeholder: 'DD/MM/YYYY',
      helpText: 'As shown on your birth certificate',
      orderIndex: 4,
      validationRules: {
        dateFormat: 'DD/MM/YYYY',
        maxDate: new Date().toISOString()
      }
    },
    {
      id: '2b3c4d5e-6f78-90ab-cdef-123456789012',
      label: 'Postal Code',
      fieldName: 'postal_code',
      fieldType: 'text',
      isRequired: true,
      placeholder: 'Enter postal code',
      helpText: 'Current address postal code',
      orderIndex: 5,
      validationRules: {
        alphanumeric: true,
        maxLength: 10
      }
    }
  ];

  for (const fieldData of personalFields) {
    const field = fieldRepository.create({
      ...fieldData,
      section: personalInfoSection
    });
    await fieldRepository.save(field);
  }

  console.log('✅ Created Personal Information section with 5 fields');

  // Section 2: Document Information
  const documentInfoSection = sectionRepository.create({
    id: '3c4d5e6f-7890-abcd-ef12-34567890abcd',
    title: 'Document Information',
    description: 'Information about the document you need to recover',
    pageNumber: 2,
    orderIndex: 2,
    form: idRecoveryForm
  });

  await sectionRepository.save(documentInfoSection);

  // Document Information Fields
  const documentFields = [
    {
      id: '4d5e6f78-90ab-cdef-1234-567890abcdef',
      label: 'Document Type',
      fieldName: 'document_type',
      fieldType: 'dropdown',
      isRequired: true,
      placeholder: 'Select document type',
      helpText: 'Choose the type of document you need to recover',
      orderIndex: 1,
      options: {
        dataSource: 'custom',
        customOptions: [
          { label: 'National ID Card', value: 'national_id' },
          { label: 'Passport', value: 'passport' },
          { label: 'Driver\'s License', value: 'drivers_license' },
          { label: 'Birth Certificate', value: 'birth_certificate' }
        ]
      }
    },
    {
      id: '5e6f7890-abcd-ef12-3456-7890abcdef12',
      label: 'Previous Document Number',
      fieldName: 'previous_document_number',
      fieldType: 'text',
      isRequired: false,
      placeholder: 'Enter previous document number if known',
      helpText: 'If you remember your previous document number',
      orderIndex: 2,
      validationRules: {
        alphanumeric: true,
        maxLength: 20
      }
    },
    {
      id: '6f789012-3456-7890-abcd-ef123456789a',
      label: 'Date of Loss',
      fieldName: 'date_of_loss',
      fieldType: 'date',
      isRequired: true,
      placeholder: 'When did you lose the document?',
      helpText: 'Approximate date when document was lost',
      orderIndex: 3,
      validationRules: {
        dateFormat: 'DD/MM/YYYY',
        maxDate: new Date().toISOString()
      }
    },
    {
      id: '7890abcd-ef12-3456-7890-abcdef123456',
      label: 'Reason for Application',
      fieldName: 'reason_for_application',
      fieldType: 'dropdown',
      isRequired: true,
      placeholder: 'Select reason',
      helpText: 'Why do you need a new document?',
      orderIndex: 4,
      options: {
        dataSource: 'custom',
        customOptions: [
          { label: 'Lost', value: 'lost' },
          { label: 'Stolen', value: 'stolen' },
          { label: 'Damaged', value: 'damaged' },
          { label: 'Expired', value: 'expired' }
        ]
      }
    }
  ];

  for (const fieldData of documentFields) {
    const field = fieldRepository.create({
      ...fieldData,
      section: documentInfoSection
    });
    await fieldRepository.save(field);
  }

  console.log('✅ Created Document Information section with 4 fields');

  // Section 3: Supporting Documents
  const supportingDocsSection = sectionRepository.create({
    id: '890abcde-f123-4567-890a-bcdef1234567',
    title: 'Supporting Documents',
    description: 'Upload required supporting documents',
    pageNumber: 3,
    orderIndex: 3,
    form: idRecoveryForm
  });

  await sectionRepository.save(supportingDocsSection);

  // Supporting Documents Fields
  const supportingFields = [
    {
      id: '90abcdef-1234-5678-90ab-cdef12345678',
      label: 'Birth Certificate',
      fieldName: 'birth_certificate',
      fieldType: 'document_upload',
      isRequired: true,
      placeholder: 'Upload your birth certificate',
      helpText: 'Clear scan or photo of your birth certificate',
      orderIndex: 1,
      validationRules: {
        allowedFileTypes: ['image/jpeg', 'image/png', 'application/pdf'],
        maxFileSize: 5242880, // 5MB
        maxFileCount: 1
      }
    },
    {
      id: 'abcdef12-3456-7890-abcd-ef1234567890',
      label: 'Proof of Address',
      fieldName: 'proof_of_address',
      fieldType: 'document_upload',
      isRequired: true,
      placeholder: 'Upload proof of current address',
      helpText: 'Utility bill, bank statement, or official mail (within 3 months)',
      orderIndex: 2,
      validationRules: {
        allowedFileTypes: ['image/jpeg', 'image/png', 'application/pdf'],
        maxFileSize: 5242880, // 5MB
        maxFileCount: 1
      }
    },
    {
      id: 'bcdef123-4567-890a-bcde-f12345678901',
      label: 'Police Report (if stolen)',
      fieldName: 'police_report',
      fieldType: 'document_upload',
      isRequired: false,
      placeholder: 'Upload police report if document was stolen',
      helpText: 'Required only if document was stolen',
      orderIndex: 3,
      validationRules: {
        allowedFileTypes: ['image/jpeg', 'image/png', 'application/pdf'],
        maxFileSize: 5242880, // 5MB
        maxFileCount: 1
      }
    },
    {
      id: 'cdef1234-5678-90ab-cdef-123456789012',
      label: 'Photo ID',
      fieldName: 'photo_id',
      fieldType: 'document_upload',
      isRequired: true,
      placeholder: 'Upload any current photo ID',
      helpText: 'Any government-issued photo ID (passport, driver\'s license, etc.)',
      orderIndex: 4,
      validationRules: {
        allowedFileTypes: ['image/jpeg', 'image/png'],
        maxFileSize: 3145728, // 3MB
        maxFileCount: 1
      }
    }
  ];

  for (const fieldData of supportingFields) {
    const field = fieldRepository.create({
      ...fieldData,
      section: supportingDocsSection
    });
    await fieldRepository.save(field);
  }

  console.log('✅ Created Supporting Documents section with 4 fields');

  // Section 4: Additional Information
  const additionalInfoSection = sectionRepository.create({
    id: 'def12345-6789-0abc-def1-23456789abcd',
    title: 'Additional Information',
    description: 'Additional details for processing your application',
    pageNumber: 4,
    orderIndex: 4,
    form: idRecoveryForm
  });

  await sectionRepository.save(additionalInfoSection);

  // Additional Information Fields
  const additionalFields = [
    {
      id: 'ef123456-789a-bcde-f123-456789abcdef',
      label: 'Special Circumstances',
      fieldName: 'special_circumstances',
      fieldType: 'textarea',
      isRequired: false,
      placeholder: 'Describe any special circumstances...',
      helpText: 'Any additional information that might help process your application',
      orderIndex: 1,
      validationRules: {
        maxLength: 500
      }
    },
    {
      id: 'f1234567-89ab-cdef-1234-56789abcdef1',
      label: 'Preferred Contact Method',
      fieldName: 'preferred_contact_method',
      fieldType: 'radio_button',
      isRequired: true,
      placeholder: 'How would you like to be contacted?',
      helpText: 'Choose your preferred method for updates',
      orderIndex: 2,
      options: {
        options: [
          { label: 'Email', value: 'email' },
          { label: 'SMS', value: 'sms' },
          { label: 'Phone Call', value: 'phone' }
        ],
        defaultSelection: 'email'
      }
    },
    {
      id: '12345678-9abc-def1-2345-6789abcdef12',
      label: 'Urgent Processing',
      fieldName: 'urgent_processing',
      fieldType: 'checkbox',
      isRequired: false,
      placeholder: 'Request urgent processing (additional fees apply)',
      helpText: 'Check if you need expedited processing',
      orderIndex: 3,
      options: {
        options: [
          { label: 'Yes, I need urgent processing (+$50)', value: 'yes' }
        ]
      }
    }
  ];

  for (const fieldData of additionalFields) {
    const field = fieldRepository.create({
      ...fieldData,
      section: additionalInfoSection
    });
    await fieldRepository.save(field);
  }

  console.log('✅ Created Additional Information section with 3 fields');

  await AppDataSource.destroy();
  console.log('🎉 ID Recovery Form seeded successfully!');
  console.log('📋 Form ID: fa79a916-e02d-4e41-888f-ccbd7af664b4');
  console.log('📑 Total sections: 4');
  console.log('📝 Total fields: 16');
}

// Run the seeder
seedIdRecoveryForm().catch(console.error);
