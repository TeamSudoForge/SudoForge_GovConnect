// Example: Creating ID Recovery Form using Dynamic Forms API

const idRecoveryFormData = {
  title: "ID Recovery Process",
  description: "Complete this form to recover your national ID",
  isActive: true,
  version: 1,
  metadata: {
    category: "identity",
    estimatedTime: "10 minutes"
  },
  sections: [
    // Page 1 - Overview (handled by static screen)
    // Page 2 - Personal Information
    {
      title: "Personal Information",
      description: "Provide your personal details for verification",
      pageNumber: 2,
      orderIndex: 1,
      fields: [
        {
          label: "Email Address",
          fieldName: "email",
          fieldType: "email",
          isRequired: true,
          placeholder: "Enter your email address",
          helpText: "We'll use this to contact you about your request",
          orderIndex: 1,
          validationRules: {
            pattern: "^[^@]+@[^@]+\\.[^@]+$",
            patternMessage: "Please enter a valid email address"
          }
        },
        {
          label: "Mobile Number",
          fieldName: "mobileNumber",
          fieldType: "phone_number",
          isRequired: true,
          placeholder: "771234567",
          helpText: "Enter your mobile number without country code",
          orderIndex: 2,
          validationRules: {
            minLength: 9,
            maxLength: 10,
            pattern: "^[0-9]+$",
            patternMessage: "Mobile number should contain only digits"
          }
        },
        {
          label: "Telephone Number",
          fieldName: "telephoneNumber",
          fieldType: "phone_number",
          isRequired: false,
          placeholder: "011-2345678",
          helpText: "Optional landline number",
          orderIndex: 3
        },
        {
          label: "Date of Birth",
          fieldName: "dateOfBirth",
          fieldType: "date",
          isRequired: true,
          placeholder: "Select your date of birth",
          orderIndex: 4,
          validationRules: {
            maxDate: "2005-12-31", // Must be at least 18 years old
            minDate: "1900-01-01"
          }
        }
      ]
    },
    // Page 3 - Location Information
    {
      title: "Location Information",
      description: "Provide your administrative division details",
      pageNumber: 3,
      orderIndex: 2,
      fields: [
        {
          label: "District Secretary Division",
          fieldName: "districtSecretaryDivision",
          fieldType: "dropdown",
          isRequired: true,
          placeholder: "Select District Secretary Division",
          orderIndex: 1,
          options: {
            options: [
              { value: "colombo_1", label: "Colombo 01" },
              { value: "colombo_2", label: "Colombo 02" },
              { value: "colombo_3", label: "Colombo 03" },
              { value: "gampaha", label: "Gampaha" },
              { value: "kalutara", label: "Kalutara" },
              { value: "kandy", label: "Kandy" }
            ]
          }
        },
        {
          label: "Village Officer Division",
          fieldName: "villageOfficerDivision",
          fieldType: "dropdown",
          isRequired: true,
          placeholder: "Select Village Officer Division",
          orderIndex: 2,
          options: {
            options: [
              { value: "village_1", label: "Village Officer Division 1" },
              { value: "village_2", label: "Village Officer Division 2" },
              { value: "village_3", label: "Village Officer Division 3" },
              { value: "village_4", label: "Village Officer Division 4" }
            ]
          }
        },
        {
          label: "Address",
          fieldName: "address",
          fieldType: "textarea",
          isRequired: true,
          placeholder: "Enter your full address",
          helpText: "Provide your complete residential address",
          orderIndex: 3,
          metadata: {
            maxLines: 3
          },
          validationRules: {
            minLength: 10,
            maxLength: 200
          }
        }
      ]
    },
    // Page 4 - Documents
    {
      title: "Supporting Documents",
      description: "Upload required documents for verification",
      pageNumber: 4,
      orderIndex: 3,
      fields: [
        {
          label: "Identity Verification Documents",
          fieldName: "identityDocuments",
          fieldType: "document_upload",
          isRequired: true,
          helpText: "Upload birth certificate, passport, or other identity documents (PDF, JPG, PNG only)",
          orderIndex: 1,
          validationRules: {
            allowedExtensions: ["pdf", "jpg", "jpeg", "png"],
            maxFileSizeMB: 5
          },
          metadata: {
            maxFiles: 3
          }
        },
        {
          label: "Reason for ID Recovery",
          fieldName: "recoveryReason",
          fieldType: "radio_button",
          isRequired: true,
          helpText: "Select the reason why you need to recover your ID",
          orderIndex: 2,
          options: {
            options: [
              { value: "lost", label: "Lost my ID" },
              { value: "stolen", label: "ID was stolen" },
              { value: "damaged", label: "ID is damaged" },
              { value: "never_received", label: "Never received my ID" },
              { value: "other", label: "Other reason" }
            ]
          }
        },
        {
          label: "Additional Services",
          fieldName: "additionalServices",
          fieldType: "checkbox",
          isRequired: false,
          helpText: "Select any additional services you need (optional)",
          orderIndex: 3,
          options: {
            options: [
              { value: "urgent_processing", label: "Urgent Processing (+$10)" },
              { value: "home_delivery", label: "Home Delivery (+$5)" },
              { value: "sms_updates", label: "SMS Status Updates" },
              { value: "email_updates", label: "Email Status Updates" }
            ]
          }
        }
      ]
    }
  ]
};

// To create this form, make a POST request to /api/dynamic-forms
// POST /api/dynamic-forms
// Authorization: Bearer <jwt_token>
// Content-Type: application/json
// Body: idRecoveryFormData

export default idRecoveryFormData;
