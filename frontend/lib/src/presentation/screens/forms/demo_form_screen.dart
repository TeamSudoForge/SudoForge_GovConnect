import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gov_connect/src/core/models/dynamic_form_models.dart';
import 'package:gov_connect/src/core/services/form_api_service.dart';
import 'package:gov_connect/src/core/services/auth_service.dart';
import 'package:gov_connect/src/presentation/widgets/form_fields/dependency_form_field.dart';
import 'package:gov_connect/src/presentation/widgets/dynamic_form_renderer.dart';

class DemoFormScreen extends StatefulWidget {
  final String? formId;
  final Map<String, dynamic>? jsonFormData;
  static const String routeName = '/demo-form';

  const DemoFormScreen({Key? key, this.formId, this.jsonFormData})
    : super(key: key);

  @override
  _DemoFormScreenState createState() => _DemoFormScreenState();
}

class _DemoFormScreenState extends State<DemoFormScreen>
    with TickerProviderStateMixin {
  int currentStep = 1;
  final int totalSteps = 3;
  int currentFormPage = 1; // For handling multiple pages within step 2
  int totalFormPages = 1; // Will be dynamically calculated
  Map<String, dynamic> _formData = {};
  late List<DynamicFormFieldModel> _dependencyFields;
  late DynamicFormModel _completeFormModel;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // API Service
  late FormApiService _formApiService;

  // Loading state
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers for submission
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  bool _isSubmitting = false;

  // Hardcoded form IDs as requested
  static const List<String> _availableFormIds = [
    '8f65c305-8c2a-4346-bc20-7c727ddb911c',
    'fa79a916-e02d-4e41-888f-ccbd7af664b4',
  ];

  @override
  void initState() {
    super.initState();
    _formApiService = FormApiService(AuthService());
    _initializeAnimations();
    _loadFormData();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  Future<void> _loadFormData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic>? jsonData;

      if (widget.jsonFormData != null) {
        // Use provided JSON data
        print('📋 Using provided JSON data');
        jsonData = widget.jsonFormData;
      } else {
        // Determine which form ID to use
        String formIdToLoad;
        if (widget.formId != null &&
            _availableFormIds.contains(widget.formId)) {
          formIdToLoad = widget.formId!;
        } else {
          // Default to the first hardcoded form ID
          formIdToLoad = _availableFormIds.first;
        }

        print('🆔 Loading form with ID: $formIdToLoad');

        // Test connection first
        final isConnected = await _formApiService.testConnection();
        print('🌐 API connection test: ${isConnected ? 'SUCCESS' : 'FAILED'}');

        if (!isConnected) {
          throw Exception('Cannot connect to backend API');
        }

        // Skip auth check for now
        // Check authentication
        // final authService = AuthService();
        // final isAuthenticated = authService.isAuthenticated;
        // final token = await authService.getToken();
        // print('🔐 Authentication status: $isAuthenticated');
        // print('🎟️ Token available: ${token != null}');

        // if (!isAuthenticated || token == null) {
        //   throw Exception('User not authenticated - please log in first');
        // }

        // Fetch form data from API
        jsonData = await _formApiService.getFormConfig(formIdToLoad);

        if (jsonData == null) {
          throw Exception(
            'Failed to load form configuration - API returned null',
          );
        }

        // Transform backend format to frontend format
        jsonData = _transformBackendResponse(jsonData);

        print('✅ Successfully loaded and transformed form data from API');
      }

      _initializeCompleteFormModel(jsonData);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('💥 Error in _loadFormData: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading form: ${e.toString()}';
      });

      // Fallback to sample data if API fails
      print('🔄 Falling back to sample data');
      _initializeCompleteFormModel(_getSampleJsonData());
    }
  }

  void _initializeCompleteFormModel([Map<String, dynamic>? jsonData]) {
    // Use provided JSON data or fallback to sample data
    final data = jsonData ?? widget.jsonFormData ?? _getSampleJsonData();

    // Parse the JSON into DynamicFormModel
    _completeFormModel = DynamicFormModel.fromJson(data);

    // Extract dependency fields from the overview section (first section with pageNumber 1)
    final overviewSection = _completeFormModel.sections.firstWhere(
      (section) => section.pageNumber == 1,
      orElse: () => _completeFormModel.sections.first,
    );
    _dependencyFields = overviewSection.fields
        .where((field) => field.fieldType == DynamicFieldType.dependencyForm)
        .toList();

    // Calculate total form pages (excluding overview and submit pages)
    final formPageNumbers =
        _completeFormModel.sections
            .where(
              (section) => section.pageNumber != 1 && section.pageNumber != 3,
            )
            .map((section) => section.pageNumber)
            .toSet()
            .toList()
          ..sort();
    totalFormPages = formPageNumbers.length;

    // Initialize form data with default values from JSON
    _initializeFormDataFromJson(data);
  }

  void _initializeFormDataFromJson(Map<String, dynamic> jsonData) {
    // Safely handle defaultValues casting
    final defaultValuesRaw = jsonData['defaultValues'];
    Map<String, dynamic> defaultValues = {};

    if (defaultValuesRaw != null) {
      if (defaultValuesRaw is Map<String, dynamic>) {
        defaultValues = defaultValuesRaw;
      } else if (defaultValuesRaw is Map) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        defaultValues = Map<String, dynamic>.from(defaultValuesRaw);
      }
    }

    _formData = Map<String, dynamic>.from(defaultValues);
  }

  Map<String, dynamic> _transformBackendResponse(
    Map<String, dynamic> backendData,
  ) {
    print('🔄 Transforming backend response to frontend format');

    // Create a deep copy to avoid modifying the original data
    final transformedData =
        json.decode(json.encode(backendData)) as Map<String, dynamic>;

    // Add defaultValues if missing
    if (!transformedData.containsKey('defaultValues')) {
      transformedData['defaultValues'] = <String, dynamic>{};
    }

    // Transform sections and fields
    if (transformedData.containsKey('sections') &&
        transformedData['sections'] is List) {
      final sections = transformedData['sections'] as List;
      for (var sectionData in sections) {
        if (sectionData is Map && sectionData['fields'] is List) {
          final fields = sectionData['fields'] as List;
          for (var fieldData in fields) {
            if (fieldData is Map && fieldData['fieldType'] is String) {
              // Transform field types
              fieldData['fieldType'] = _transformFieldType(
                fieldData['fieldType'] as String,
              );
            }
          }
        }
      }
    }

    print('✅ Backend response transformed successfully');
    return transformedData;
  }

  String _transformFieldType(String backendFieldType) {
    // Transform backend field types to frontend expected format
    final fieldTypeMap = {
      'text': 'text',
      'phone_number': 'phoneNumber',
      'email': 'email',
      'document_upload': 'documentUpload',
      'date': 'date',
      'dropdown': 'dropdown',
      'radio_button': 'radioButton',
      'checkbox': 'checkbox',
      'textarea': 'textarea',
      'number': 'number',
      'dependency_form': 'dependencyForm',
    };

    return fieldTypeMap[backendFieldType] ?? backendFieldType;
  }

  // Sample JSON data structure for testing
  Map<String, dynamic> _getSampleJsonData() {
    final now = DateTime.now().toIso8601String();

    return {
      "id": "fa79a916-e02d-4e41-888f-ccbd7af664b4",
      "title": "ID Recovery Application",
      "description":
          "Apply for official identity document recovery services through our secure digital platform",
      "isActive": true,
      "version": 1,
      "metadata": {
        "department": "Immigration Department",
        "announcementUrl": "https://example.com/announcement",
      },
      "createdAt": now,
      "updatedAt": now,
      "defaultValues": {
        "personal_profile_completed": false,
        "address_verification_completed": false,
        "emergency_contact_completed": true,
      },
      "sections": [
        {
          "id": "overview-section",
          "title": "Auto-filled Data Requirements",
          "description":
              "Complete the following forms to auto-populate your application data",
          "pageNumber": 1,
          "orderIndex": 1,
          "formId": "fa79a916-e02d-4e41-888f-ccbd7af664b4",
          "createdAt": now,
          "updatedAt": now,
          "fields": [
            {
              "id": "profile-form-dep",
              "label": "Personal Profile Information",
              "fieldName": "personal_profile_completed",
              "fieldType": "dependencyForm",
              "isRequired": true,
              "placeholder": null,
              "helpText":
                  "Complete your basic personal information including name, date of birth, and contact details. This information will be used to verify your identity.",
              "orderIndex": 1,
              "validationRules": null,
              "options": null,
              "metadata": {"formUrl": "/profile-setup", "isFilled": false},
              "sectionId": "overview-section",
              "createdAt": now,
              "updatedAt": now,
            },
            {
              "id": "address-form-dep",
              "label": "Address Verification",
              "fieldName": "address_verification_completed",
              "fieldType": "dependencyForm",
              "isRequired": true,
              "placeholder": null,
              "helpText":
                  "Provide and verify your current residential address. This helps us ensure accurate document delivery.",
              "orderIndex": 2,
              "validationRules": null,
              "options": null,
              "metadata": {
                "formUrl": "/address-verification",
                "isFilled": false,
              },
              "sectionId": "overview-section",
              "createdAt": now,
              "updatedAt": now,
            },
            {
              "id": "emergency-contact-dep",
              "label": "Emergency Contact Information",
              "fieldName": "emergency_contact_completed",
              "fieldType": "dependencyForm",
              "isRequired": false,
              "placeholder": null,
              "helpText":
                  "Provide emergency contact details for security purposes and in case we need to verify your identity.",
              "orderIndex": 3,
              "validationRules": null,
              "options": null,
              "metadata": {"formUrl": "/emergency-contact", "isFilled": true},
              "sectionId": "overview-section",
              "createdAt": now,
              "updatedAt": now,
            },
          ],
        },
        {
          "id": "2fd6cc13-4b2b-4b51-b7df-81f89fe6af69",
          "title": "Application Details",
          "description": "Basic information about your ID recovery request",
          "pageNumber": 2,
          "orderIndex": 2,
          "formId": "fa79a916-e02d-4e41-888f-ccbd7af664b4",
          "createdAt": now,
          "updatedAt": now,
          "fields": [
            {
              "id": "reason-for-recovery",
              "label": "Reason for ID Recovery",
              "fieldName": "recovery_reason",
              "fieldType": "dropdown",
              "isRequired": true,
              "placeholder": "Select reason",
              "helpText": "Please specify why you need to recover your ID",
              "orderIndex": 1,
              "validationRules": null,
              "options": {
                "options": [
                  {"value": "lost", "label": "Lost"},
                  {"value": "stolen", "label": "Stolen"},
                  {"value": "damaged", "label": "Damaged"},
                  {"value": "expired", "label": "Expired"},
                ],
              },
              "metadata": null,
              "sectionId": "2fd6cc13-4b2b-4b51-b7df-81f89fe6af69",
              "createdAt": now,
              "updatedAt": now,
            },
            {
              "id": "incident-date",
              "label": "Date of Incident",
              "fieldName": "incident_date",
              "fieldType": "date",
              "isRequired": false,
              "placeholder": null,
              "helpText":
                  "When did you realize your ID was lost/stolen/damaged?",
              "orderIndex": 2,
              "validationRules": null,
              "options": null,
              "metadata": null,
              "sectionId": "2fd6cc13-4b2b-4b51-b7df-81f89fe6af69",
              "createdAt": now,
              "updatedAt": now,
            },
          ],
        },
        {
          "id": "additional-info-section",
          "title": "Additional Information",
          "description": "Provide additional details for your application",
          "pageNumber": 4,
          "orderIndex": 3,
          "formId": "fa79a916-e02d-4e41-888f-ccbd7af664b4",
          "createdAt": now,
          "updatedAt": now,
          "fields": [
            {
              "id": "additional-details",
              "label": "Additional Details",
              "fieldName": "additional_details",
              "fieldType": "textarea",
              "isRequired": false,
              "placeholder": "Provide any additional information...",
              "helpText":
                  "Any other relevant information about your ID recovery request",
              "orderIndex": 1,
              "validationRules": null,
              "options": null,
              "metadata": {"maxLines": 4},
              "sectionId": "additional-info-section",
              "createdAt": now,
              "updatedAt": now,
            },
            {
              "id": "emergency-contact-name",
              "label": "Emergency Contact Name",
              "fieldName": "emergency_contact_name",
              "fieldType": "text",
              "isRequired": false,
              "placeholder": "Enter emergency contact name",
              "helpText": "Name of person to contact in case of emergency",
              "orderIndex": 2,
              "validationRules": null,
              "options": null,
              "metadata": null,
              "sectionId": "additional-info-section",
              "createdAt": now,
              "updatedAt": now,
            },
            {
              "id": "emergency-contact-phone",
              "label": "Emergency Contact Phone",
              "fieldName": "emergency_contact_phone",
              "fieldType": "phoneNumber",
              "isRequired": false,
              "placeholder": "Enter phone number",
              "helpText": "Phone number of emergency contact",
              "orderIndex": 3,
              "validationRules": null,
              "options": null,
              "metadata": null,
              "sectionId": "additional-info-section",
              "createdAt": now,
              "updatedAt": now,
            },
          ],
        },
        {
          "id": "989a6047-d355-4b21-a59f-2d6e942dc082",
          "title": "Supporting Documents",
          "description":
              "Upload required supporting documents for verification",
          "pageNumber": 3,
          "orderIndex": 4,
          "formId": "fa79a916-e02d-4e41-888f-ccbd7af664b4",
          "createdAt": now,
          "updatedAt": now,
          "fields": [
            {
              "id": "a8c73444-21b3-4aef-bca3-209a10f306df",
              "label": "Birth Certificate",
              "fieldName": "birth_certificate",
              "fieldType": "documentUpload",
              "isRequired": true,
              "placeholder": null,
              "helpText":
                  "Upload a clear, legible copy of your birth certificate",
              "orderIndex": 1,
              "validationRules": {
                "allowedExtensions": ["pdf", "jpg", "png"],
                "maxFileSizeMB": 5,
              },
              "options": null,
              "metadata": {"maxFiles": 1},
              "sectionId": "989a6047-d355-4b21-a59f-2d6e942dc082",
              "createdAt": now,
              "updatedAt": now,
            },
            {
              "id": "69bf2b4a-2cfc-4074-a36d-71b53d4047e1",
              "label": "Proof of Address",
              "fieldName": "address_proof",
              "fieldType": "documentUpload",
              "isRequired": true,
              "placeholder": null,
              "helpText":
                  "Utility bill, bank statement, or lease agreement (not older than 3 months)",
              "orderIndex": 2,
              "validationRules": {
                "allowedExtensions": ["pdf", "jpg", "png"],
                "maxFileSizeMB": 5,
              },
              "options": null,
              "metadata": {"maxFiles": 2},
              "sectionId": "989a6047-d355-4b21-a59f-2d6e942dc082",
              "createdAt": now,
              "updatedAt": now,
            },
            {
              "id": "police-report-upload",
              "label": "Police Report (if applicable)",
              "fieldName": "police_report",
              "fieldType": "documentUpload",
              "isRequired": false,
              "placeholder": null,
              "helpText":
                  "Required if ID was stolen. Upload police report or incident number",
              "orderIndex": 3,
              "validationRules": {
                "allowedExtensions": ["pdf", "jpg", "png"],
                "maxFileSizeMB": 5,
              },
              "options": null,
              "metadata": {"maxFiles": 1},
              "sectionId": "989a6047-d355-4b21-a59f-2d6e942dc082",
              "createdAt": now,
              "updatedAt": now,
            },
          ],
        },
      ],
      "ui": {
        "overview": {
          "title": "Recover or renew your lostID",
          "description":
              "We'll guide you through every step, document, and appointment. No more confusion or wasted time.",
          "infoCards": [
            "For your convenience, the following fields have been automatically filled using the verified personal data linked to your profile.",
            "This data has been collected in accordance with applicable regulations and is securely stored. Please review and update if necessary before submission.",
          ],
          "processSteps": [
            {
              "stepNumber": 1,
              "title": "Auto Filed Data",
              "description":
                  "Check all the required auto filed data are available and correct.",
            },
            {
              "stepNumber": 2,
              "title": "ID Recovery Form",
              "description":
                  "Fill the form for ID recovery application with required details.",
            },
            {
              "stepNumber": 3,
              "title": "Submit",
              "description":
                  "Submit the form and wait until we process the request.",
            },
          ],
        },
        "stepLabels": ["Overview", "Form", "Submit"],
      },
    };
  }

  void _handleFieldChange(String fieldName, dynamic value) {
    setState(() {
      _formData[fieldName] = value;
    });
  }

  void _proceedToForm() {
    // For overview page, validate dependency forms
    if (currentStep == 1) {
      bool canProceed = true;
      String missingForms = '';

      for (final field in _dependencyFields) {
        if (field.isRequired) {
          final isFilled = _formData[field.fieldName] as bool? ?? false;
          if (!isFilled) {
            canProceed = false;
            missingForms += '${field.label}, ';
          }
        }
      }

      if (!canProceed) {
        _showMissingFormsDialog(missingForms.replaceAll(RegExp(r', $'), ''));
        return;
      }

      // Move to step 2 (first form page)
      setState(() {
        currentStep = 2;
        currentFormPage = 1;
      });
    }
    // Handle form step navigation (step 2 has multiple pages)
    else if (currentStep == 2) {
      if (currentFormPage < totalFormPages) {
        // Move to next form page within step 2
        setState(() {
          currentFormPage++;
        });
      } else {
        // Move to final step (submit)
        setState(() {
          currentStep = 3;
        });
      }
    }
    // Final submit
    else if (currentStep == 3) {
      _submitForm();
    }
  }

  void _previousStep() {
    if (currentStep == 2 && currentFormPage > 1) {
      // Go back to previous form page within step 2
      setState(() {
        currentFormPage--;
      });
    } else if (currentStep > 1) {
      // Go back to previous step
      if (currentStep == 2) {
        setState(() {
          currentStep = 1;
          currentFormPage = 1;
        });
      } else {
        setState(() {
          currentStep--;
        });
      }
    }
  }

  void _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });

    // Start animation
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _checkController.forward();

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 2000));

    // Auto-navigate to home
    if (mounted) {
      context.go('/home');
    }
  }

  void _showMissingFormsDialog(String missingForms) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Required Forms Missing'),
        content: Text(
          'Please complete the following required forms before proceeding:\n\n$missingForms',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show submission animation overlay
    if (_isSubmitting) {
      return _buildSubmissionOverlay();
    }

    // Show loading state
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    // Show error state
    if (_errorMessage != null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF2196F3), // Blue header background
      body: SafeArea(
        child: Column(
          children: [
            // Blue Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF2196F3),
              child: Column(
                children: [
                  // Top Navigation Bar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'ID Recovery Process',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Notification and Profile Icons
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Step Indicator
                  Row(
                    children: [
                      for (int i = 1; i <= totalSteps; i++) ...[
                        _buildStepIndicator(i),
                        if (i < totalSteps) _buildStepConnector(),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Step Labels
                  Row(
                    children: [
                      for (int i = 0; i < totalSteps; i++) ...[
                        Expanded(
                          child: Text(
                            _getStepLabel(i + 1),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: currentStep == (i + 1)
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // White Content Section
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildCurrentStepContent(),
                ),
              ),
            ),

            // Bottom Navigation Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Back Button
                  if (currentStep > 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),

                  // Home/Back to Home Button for first step
                  if (currentStep == 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(width: 16),

                  // Continue Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _proceedToForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _getContinueButtonText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build content based on current step
  Widget _buildCurrentStepContent() {
    switch (currentStep) {
      case 1:
        return _buildOverviewContent();
      case 2:
        return _buildFormContent();
      case 3:
        return _buildSubmitContent();
      default:
        return _buildOverviewContent();
    }
  }

  Widget _buildOverviewContent() {
    // Get UI data from form model metadata or JSON
    final jsonData = widget.jsonFormData ?? _getSampleJsonData();
    final uiConfig = jsonData['ui']?['overview'] ?? {};
    final metadata = _completeFormModel.metadata ?? {};

    final title = uiConfig['title'] ?? _completeFormModel.title;
    final description =
        uiConfig['description'] ?? _completeFormModel.description;
    final infoCards = List<String>.from(uiConfig['infoCards'] ?? []);
    final processSteps = List<Map<String, dynamic>>.from(
      uiConfig['processSteps'] ?? [],
    );
    final department = metadata['department'] ?? 'Government Department';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Title (from JSON)
        Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        // Description (from JSON)
        Center(
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Service Registration Info (from JSON)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF2196F3),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                    children: [
                      TextSpan(
                        text:
                            'This Service is registered under $department. See the ',
                      ),
                      const TextSpan(
                        text: 'Official Announcement',
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Auto-Filled Personal Information Section
        _buildSectionHeader('Auto-Filled Personal Information'),

        const SizedBox(height: 16),

        // Info cards from JSON
        ...infoCards.map(
          (cardText) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildInfoCard(cardText),
          ),
        ),

        const SizedBox(height: 32),

        // Auto Filed Data Section
        const Text(
          'Auto Filed Data',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),

        const SizedBox(height: 16),

        // Dependency Forms (from JSON)
        ..._dependencyFields.map(
          (field) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: DependencyFormField(
              label: field.label,
              fieldName: field.fieldName,
              helpText: field.helpText,
              isRequired: field.isRequired,
              metadata: field.metadata,
              value: _formData[field.fieldName] as bool?,
              onChanged: _handleFieldChange,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Process Flow Section
        const Text(
          'Process Flow',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),

        const SizedBox(height: 16),

        // Process Flow Steps (from JSON)
        ...processSteps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return _buildProcessFlowStep(
            stepNumber: step['stepNumber'] ?? (index + 1),
            title: step['title'] ?? 'Step ${index + 1}',
            description: step['description'] ?? '',
            isActive: currentStep >= (step['stepNumber'] ?? (index + 1)),
            isLast: index == processSteps.length - 1,
          );
        }),
      ],
    );
  }

  Widget _buildFormContent() {
    // Determine which page to show (page 2 for form page 1, page 4 for form page 2)
    final pageNumber = currentFormPage == 1 ? 2 : 4;

    // Get the current section for dynamic titles
    final currentSection = _completeFormModel.sections.firstWhere(
      (section) => section.pageNumber == pageNumber,
      orElse: () => _completeFormModel.sections.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Title (from JSON)
        Center(
          child: Text(
            currentSection.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        // Description (from JSON)
        Center(
          child: Text(
            currentSection.description ??
                'Please fill in the required information.',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        // Page indicator for form step
        if (totalFormPages > 1)
          Center(
            child: Text(
              'Page $currentFormPage of $totalFormPages',
              style: const TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
          ),

        const SizedBox(height: 32),

        // Dynamic Form Renderer for current form page
        DynamicFormRenderer(
          form: _completeFormModel,
          currentPage: pageNumber,
          formData: _formData,
          formKey: _formKey,
          onFieldChanged: _handleFieldChange,
        ),
      ],
    );
  }

  Widget _buildSubmitContent() {
    // Get the submit section (page 3)
    final submitSection = _completeFormModel.sections.firstWhere(
      (section) => section.pageNumber == 3,
      orElse: () => _completeFormModel.sections.last,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Title (from JSON)
        Center(
          child: Text(
            submitSection.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        // Description (from JSON)
        Center(
          child: Text(
            submitSection.description ?? 'Review and submit your application.',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 32),

        // Dynamic Form Renderer for page 3
        DynamicFormRenderer(
          form: _completeFormModel,
          currentPage: 3,
          formData: _formData,
          formKey: _formKey,
          onFieldChanged: _handleFieldChange,
        ),

        const SizedBox(height: 32),

        // Summary Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Application Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '• All dependency forms completed',
                style: TextStyle(fontSize: 14, color: Color(0xFF4CAF50)),
              ),
              const SizedBox(height: 4),
              Text(
                '• Recovery reason: ${_formData["recovery_reason"] ?? "Not specified"}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 4),
              const Text(
                '• All required documents ready for submission',
                style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods (same as ID recovery process screen)
  Widget _buildStepIndicator(int step) {
    final bool isActive = step <= currentStep;
    final bool isCompleted = step < currentStep;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Color(0xFF2196F3), size: 18)
            : Text(
                step.toString(),
                style: TextStyle(
                  color: isActive ? const Color(0xFF2196F3) : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildStepConnector() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.white.withOpacity(0.3),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFF2196F3),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF333333),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessFlowStep({
    required int stepNumber,
    required String title,
    required String description,
    required bool isActive,
    bool isLast = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number Circle
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? const Color(0xFF2196F3)
                      : const Color(0xFFE0E0E0),
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF666666),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: const Color(0xFFE0E0E0),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Step Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8), // Adjusted for better alignment
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? const Color(0xFF333333)
                        : const Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive
                        ? const Color(0xFF666666)
                        : const Color(0xFF999999),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get step label from JSON configuration
  String _getStepLabel(int stepNumber) {
    final jsonData = widget.jsonFormData ?? _getSampleJsonData();
    final stepLabels = List<String>.from(
      jsonData['ui']?['stepLabels'] ?? ['Step 1', 'Step 2', 'Step 3'],
    );

    if (stepNumber <= stepLabels.length) {
      return stepLabels[stepNumber - 1];
    }
    return 'Step $stepNumber';
  }

  // Get appropriate text for continue button
  String _getContinueButtonText() {
    if (currentStep == 1) {
      return 'Continue';
    } else if (currentStep == 2) {
      if (currentFormPage < totalFormPages) {
        return 'Next';
      } else {
        return 'Continue to Submit';
      }
    } else {
      return 'Submit Application';
    }
  }

  // Build submission animation overlay
  Widget _buildSubmissionOverlay() {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF5F5F5),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  const Text(
                    'Submitting ID Recovery\nApplication',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),

                  // Animated success icon
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _checkAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _checkAnimation.value,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4CAF50),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Success message
                  const Text(
                    'Application Submitted Successfully',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'We will inform you soon after your\napplication is processed.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF2196F3),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Loading Form...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Loading indicator
            Expanded(
              child: Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        'Loading form configuration...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF2196F3),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Error',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Error message
            Expanded(
              child: Container(
                color: Colors.white,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _errorMessage ?? 'An error occurred',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _loadFormData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 15,
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
