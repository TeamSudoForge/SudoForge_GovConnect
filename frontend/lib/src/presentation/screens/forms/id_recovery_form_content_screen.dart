import 'package:flutter/material.dart';
import 'package:gov_connect/src/presentation/widgets/form_fields/dropdown_field.dart';
import 'package:gov_connect/src/presentation/widgets/form_fields/email_input_field.dart';
import 'package:gov_connect/src/presentation/widgets/form_fields/phone_input_field.dart';
import 'package:gov_connect/src/presentation/widgets/form_fields/telephone_input_field.dart';
import 'package:go_router/go_router.dart';
import 'package:gov_connect/src/presentation/widgets/form_fields/file_upload_field.dart';

class IdRecoveryFormContentScreen extends StatefulWidget {
  const IdRecoveryFormContentScreen({Key? key}) : super(key: key);

  @override
  State<IdRecoveryFormContentScreen> createState() =>
      _IdRecoveryFormContentScreenState();
}

class _IdRecoveryFormContentScreenState
    extends State<IdRecoveryFormContentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  String? _email;
  String? _mobileNumber;
  String? _telephoneNumber;
  String? _districtSecretaryDivision;
  String? _villageOfficerDivision;
  String? _birthCertificateUrl;
  String? _proofOfAddressUrl;

  // Sample data for dropdowns - these would typically come from API
  final List<DropdownOption> _districtDivisions = [
    const DropdownOption(value: 'colombo_1', label: 'Colombo 01'),
    const DropdownOption(value: 'colombo_2', label: 'Colombo 02'),
    const DropdownOption(value: 'colombo_3', label: 'Colombo 03'),
    const DropdownOption(value: 'colombo_4', label: 'Colombo 04'),
    const DropdownOption(value: 'colombo_5', label: 'Colombo 05'),
    const DropdownOption(value: 'gampaha', label: 'Gampaha'),
    const DropdownOption(value: 'kalutara', label: 'Kalutara'),
    const DropdownOption(value: 'kandy', label: 'Kandy'),
    const DropdownOption(value: 'matale', label: 'Matale'),
    const DropdownOption(value: 'nuwara_eliya', label: 'Nuwara Eliya'),
  ];

  final List<DropdownOption> _villageOfficerDivisions = [
    const DropdownOption(
      value: 'village_1',
      label: 'Village Officer Division 1',
    ),
    const DropdownOption(
      value: 'village_2',
      label: 'Village Officer Division 2',
    ),
    const DropdownOption(
      value: 'village_3',
      label: 'Village Officer Division 3',
    ),
    const DropdownOption(
      value: 'village_4',
      label: 'Village Officer Division 4',
    ),
    const DropdownOption(
      value: 'village_5',
      label: 'Village Officer Division 5',
    ),
  ];

  void _handleFormSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_birthCertificateUrl == null || _proofOfAddressUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload all required documents.'),
          ),
        );
        return;
      }
      // Process form submission
      print('Form submitted with data:');
      print('Email: $_email');
      print('Mobile: $_mobileNumber');
      print('Telephone: $_telephoneNumber');
      print('District Secretary Division: $_districtSecretaryDivision');
      print('Village Officer Division: $_villageOfficerDivision');
      print('Birth Certificate URL: $_birthCertificateUrl');
      print('Proof of Address URL: $_proofOfAddressUrl');

      // Navigate to success screen
      context.go('/home/id-recovery-process/success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ID Recovery Process',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue header section with step indicator
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Step indicator
                    Row(
                      children: [
                        // Step 1 - completed
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF2196F3),
                            size: 18,
                          ),
                        ),
                        // Line
                        Expanded(
                          child: Container(height: 2, color: Colors.white),
                        ),
                        // Step 2 - current
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              '2',
                              style: TextStyle(
                                color: Color(0xFF2196F3),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        // Line
                        Expanded(
                          child: Container(height: 2, color: Colors.white30),
                        ),
                        // Step 3 - pending
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30, width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white30,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Title
                    const Text(
                      'Enter Your Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please provide your contact information for identity verification',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Form content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Email field
                    EmailInputField(
                      label: 'Email Address',
                      placeholder: 'Enter your email address',
                      value: _email,
                      isRequired: true,
                      onChanged: (value) => setState(() => _email = value),
                    ),
                    const SizedBox(height: 20),

                    // Mobile number field
                    PhoneInputField(
                      label: 'Mobile Number',
                      placeholder: '771234567',
                      value: _mobileNumber,
                      isRequired: true,
                      onChanged: (value) =>
                          setState(() => _mobileNumber = value),
                    ),
                    const SizedBox(height: 20),

                    // Telephone number field
                    TelephoneInputField(
                      label: 'Telephone Number',
                      placeholder: '011-2345678',
                      value: _telephoneNumber,
                      onChanged: (value) =>
                          setState(() => _telephoneNumber = value),
                    ),
                    const SizedBox(height: 20),

                    // District Secretary Division dropdown
                    DropdownField(
                      label: 'District Secretary Division',
                      placeholder: 'Select District Secretary Division',
                      value: _districtSecretaryDivision,
                      options: _districtDivisions,
                      isRequired: true,
                      onChanged: (value) =>
                          setState(() => _districtSecretaryDivision = value),
                    ),
                    const SizedBox(height: 20),

                    // Village Officer Division dropdown
                    DropdownField(
                      label: 'Village Officer Division',
                      placeholder: 'Select Village Officer Division',
                      value: _villageOfficerDivision,
                      options: _villageOfficerDivisions,
                      isRequired: true,
                      onChanged: (value) =>
                          setState(() => _villageOfficerDivision = value),
                    ),
                    const SizedBox(height: 40),

                    // Document upload section
                    const Text(
                      'Upload Required Documents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FileUploadField(
                      label: 'Birth Certificate (Photo or PDF)',
                      helperText:
                          'Upload a clear photo or PDF of your birth certificate.',
                      isRequired: true,
                      folder: 'id-recovery',
                      allowedMimeTypes: const [
                        'image/png',
                        'image/jpeg',
                        'application/pdf',
                      ],
                      onUploaded: (result) {
                        setState(() => _birthCertificateUrl = result?.url);
                      },
                    ),
                    const SizedBox(height: 16),
                    FileUploadField(
                      label: 'Proof of Address (Photo or PDF)',
                      helperText:
                          'Utility bill, bank statement, or government letter.',
                      isRequired: true,
                      folder: 'id-recovery',
                      allowedMimeTypes: const [
                        'image/png',
                        'image/jpeg',
                        'application/pdf',
                      ],
                      onUploaded: (result) {
                        setState(() => _proofOfAddressUrl = result?.url);
                      },
                    ),
                    const SizedBox(height: 40),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleFormSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Continue to Next Step',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Back button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          side: const BorderSide(color: Color(0xFF2196F3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
