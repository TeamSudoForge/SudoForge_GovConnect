import { Controller, Get, Post, Body, Param } from '@nestjs/common';
import { FieldType } from '../database/entities/form-field.entity';

// Example service overview form with dependency forms
const sampleServiceOverviewForm = {
  id: "fa79a916-e02d-4e41-888f-ccbd7af664b4",
  title: "ID Recovery Application",
  description: "Apply for official identity document recovery services through our secure digital platform",
  isActive: true,
  version: 1,
  metadata: null,
  sections: [
    {
      id: "overview-section",
      title: "Auto-filled Data Requirements",
      description: "Complete the following forms to auto-populate your application data",
      pageNumber: 1,
      orderIndex: 1,
      formId: "fa79a916-e02d-4e41-888f-ccbd7af664b4",
      fields: [
        {
          id: "profile-form-dep",
          label: "Personal Profile Information",
          fieldName: "personal_profile_completed",
          fieldType: FieldType.DEPENDENCY_FORM,
          isRequired: true,
          placeholder: null,
          helpText: "Complete your basic personal information including name, date of birth, and contact details. This information will be used to verify your identity.",
          orderIndex: 1,
          validationRules: null,
          options: null,
          metadata: {
            formUrl: "/profile-setup",
            isFilled: false,
          },
          sectionId: "overview-section",
        },
        {
          id: "address-form-dep",
          label: "Address Verification",
          fieldName: "address_verification_completed",
          fieldType: FieldType.DEPENDENCY_FORM,
          isRequired: true,
          placeholder: null,
          helpText: "Provide and verify your current residential address. This helps us ensure accurate document delivery.",
          orderIndex: 2,
          validationRules: null,
          options: null,
          metadata: {
            formUrl: "/address-verification",
            isFilled: false,
          },
          sectionId: "overview-section",
        },
        {
          id: "emergency-contact-dep",
          label: "Emergency Contact Information",
          fieldName: "emergency_contact_completed",
          fieldType: FieldType.DEPENDENCY_FORM,
          isRequired: false,
          placeholder: null,
          helpText: "Provide emergency contact details for security purposes and in case we need to verify your identity.",
          orderIndex: 3,
          validationRules: null,
          options: null,
          metadata: {
            formUrl: "/emergency-contact",
            isFilled: true, // This one is already filled
          },
          sectionId: "overview-section",
        },
      ],
    },
    // Additional form sections for the actual application...
    {
      id: "application-details",
      title: "Application Details",
      description: "Specific details about your ID recovery request",
      pageNumber: 2,
      orderIndex: 2,
      formId: "fa79a916-e02d-4e41-888f-ccbd7af664b4",
      fields: [
        {
          id: "reason-for-recovery",
          label: "Reason for ID Recovery",
          fieldName: "recovery_reason",
          fieldType: FieldType.DROPDOWN,
          isRequired: true,
          placeholder: "Select reason",
          helpText: "Please specify why you need to recover your ID",
          orderIndex: 1,
          validationRules: null,
          options: {
            options: [
              { value: "lost", label: "Lost" },
              { value: "stolen", label: "Stolen" },
              { value: "damaged", label: "Damaged" },
              { value: "expired", label: "Expired" },
            ]
          },
          metadata: null,
          sectionId: "application-details",
        }
      ],
    }
  ],
};

@Controller('examples')
export class ExampleDependencyFormController {
  
  @Get('service-overview-form')
  getServiceOverviewForm() {
    return {
      success: true,
      data: sampleServiceOverviewForm
    };
  }

  @Post('dependency-form-status/:fieldName')
  updateDependencyFormStatus(
    @Param('fieldName') fieldName: string,
    @Body('isFilled') isFilled: boolean
  ) {
    // In a real application, this would update the database
    // to mark the dependency form as completed for the user
    return {
      success: true,
      message: `Dependency form ${fieldName} marked as ${isFilled ? 'completed' : 'incomplete'}`,
      data: {
        fieldName,
        isFilled,
        updatedAt: new Date().toISOString()
      }
    };
  }

  @Get('dependency-form-status/:userId/:fieldName')
  getDependencyFormStatus(
    @Param('userId') userId: string,
    @Param('fieldName') fieldName: string
  ) {
    // In a real application, this would check the database
    // for the user's completion status of the dependency form
    const mockStatuses: { [key: string]: boolean } = {
      'personal_profile_completed': false,
      'address_verification_completed': false,
      'emergency_contact_completed': true, // This one is completed
    };

    return {
      success: true,
      data: {
        fieldName,
        isFilled: mockStatuses[fieldName] || false,
        userId,
        lastUpdated: new Date().toISOString()
      }
    };
  }
}
