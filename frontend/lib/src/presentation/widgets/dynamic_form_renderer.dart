import 'package:flutter/material.dart';
import '../../core/models/dynamic_form_models.dart';
import 'form_fields/text_input_field.dart';
import 'form_fields/email_input_field.dart';
import 'form_fields/phone_input_field.dart';
import 'form_fields/telephone_input_field.dart';
import 'form_fields/dropdown_field.dart';
import 'form_fields/dynamic_textarea_field.dart';
import 'form_fields/dynamic_date_field.dart';
import 'form_fields/dynamic_radio_button_field.dart';
import 'form_fields/dynamic_checkbox_field.dart';
import 'form_fields/dynamic_number_field.dart';
import 'form_fields/dynamic_document_upload_field.dart';
import 'form_fields/dependency_form_field.dart';

class DynamicFormRenderer extends StatefulWidget {
  final DynamicFormModel form;
  final int currentPage;
  final Map<String, dynamic> formData;
  final Function(String fieldName, dynamic value)? onFieldChanged;
  final GlobalKey<FormState>? formKey;

  const DynamicFormRenderer({
    Key? key,
    required this.form,
    this.currentPage = 1,
    required this.formData,
    this.onFieldChanged,
    this.formKey,
  }) : super(key: key);

  @override
  State<DynamicFormRenderer> createState() => _DynamicFormRendererState();
}

class _DynamicFormRendererState extends State<DynamicFormRenderer> {
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    final sectionsForPage = widget.form.getSectionsForPage(widget.currentPage);

    if (sectionsForPage.isEmpty) {
      return const Center(
        child: Text(
          'No sections found for this page',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sectionsForPage.map((section) {
          return _buildSection(section);
        }).toList(),
      ),
    );
  }

  Widget _buildSection(DynamicFormSectionModel section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          if (section.description != null) ...[
            const SizedBox(height: 8),
            Text(
              section.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
          ],
          const SizedBox(height: 16),
          
          // Section fields
          Column(
            children: section.fields.map((field) {
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: _buildField(field),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildField(DynamicFormFieldModel field) {
    switch (field.fieldType) {
      case DynamicFieldType.text:
        return TextInputField(
          label: field.label,
          placeholder: field.placeholder,
          value: widget.formData[field.fieldName]?.toString(),
          isRequired: field.isRequired,
          onChanged: (value) => _handleFieldChange(field.fieldName, value),

        );

      case DynamicFieldType.email:
        return EmailInputField(
          label: field.label,
          placeholder: field.placeholder,
          value: widget.formData[field.fieldName]?.toString(),
          isRequired: field.isRequired,
          onChanged: (value) => _handleFieldChange(field.fieldName, value),
        );

      case DynamicFieldType.phoneNumber:
        return PhoneInputField(
          label: field.label,
          placeholder: field.placeholder,
          value: widget.formData[field.fieldName]?.toString(),
          isRequired: field.isRequired,
          onChanged: (value) => _handleFieldChange(field.fieldName, value),
        );

      case DynamicFieldType.textarea:
        return DynamicTextAreaField(
          label: field.label,
          placeholder: field.placeholder,
          value: widget.formData[field.fieldName]?.toString(),
          isRequired: field.isRequired,
          helpText: field.helpText,
          onChanged: (value) => _handleFieldChange(field.fieldName, value),
          maxLines: field.metadata?['maxLines'] ?? 4,
        );

      case DynamicFieldType.number:
        return DynamicNumberField(
          label: field.label,
          placeholder: field.placeholder,
          value: widget.formData[field.fieldName]?.toString(),
          isRequired: field.isRequired,
          helpText: field.helpText,
          onChanged: (value) => _handleFieldChange(field.fieldName, value),
          allowDecimals: field.metadata?['allowDecimals'] ?? true,
          minValue: field.validationRules?['min']?.toDouble(),
          maxValue: field.validationRules?['max']?.toDouble(),
        );

      case DynamicFieldType.date:
        return DynamicDateField(
          label: field.label,
          placeholder: field.placeholder,
          value: widget.formData[field.fieldName]?.toString(),
          isRequired: field.isRequired,
          helpText: field.helpText,
          onChanged: (value) => _handleFieldChange(field.fieldName, value),
          firstDate: field.validationRules?['minDate'] != null 
            ? DateTime.parse(field.validationRules!['minDate'])
            : null,
          lastDate: field.validationRules?['maxDate'] != null 
            ? DateTime.parse(field.validationRules!['maxDate'])
            : null,
        );

      case DynamicFieldType.dropdown:
        return DropdownField(
          label: field.label,
          placeholder: field.placeholder,
          value: widget.formData[field.fieldName]?.toString(),
          isRequired: field.isRequired,
          options: _parseDropdownOptions(field.options),
          onChanged: (value) => _handleFieldChange(field.fieldName, value),
        );

      case DynamicFieldType.radioButton:
        return DynamicRadioButtonField(
          label: field.label,
          value: widget.formData[field.fieldName]?.toString(),
          isRequired: field.isRequired,
          helpText: field.helpText,
          options: _parseOptions(field.options),
          onChanged: (value) => _handleFieldChange(field.fieldName, value),
        );

      case DynamicFieldType.checkbox:
        return DynamicCheckboxField(
          label: field.label,
          value: widget.formData[field.fieldName] != null 
            ? List<String>.from(widget.formData[field.fieldName])
            : null,
          isRequired: field.isRequired,
          helpText: field.helpText,
          options: _parseOptions(field.options),
          onChanged: (value) => _handleFieldChange(field.fieldName, value),
        );

      case DynamicFieldType.documentUpload:
        return DynamicDocumentUploadField(
          label: field.label,
          value: widget.formData[field.fieldName] != null 
            ? List<String>.from(widget.formData[field.fieldName])
            : null,
          isRequired: field.isRequired,
          helpText: field.helpText,
          onChanged: (value) => _handleFieldChange(field.fieldName, value),
          allowedExtensions: field.validationRules?['allowedExtensions']?.cast<String>(),
          maxFiles: field.metadata?['maxFiles'] ?? 5,
          maxFileSizeMB: field.validationRules?['maxFileSizeMB'],
        );

      case DynamicFieldType.dependencyForm:
        return DependencyFormField(
          label: field.label,
          fieldName: field.fieldName,
          helpText: field.helpText,
          isRequired: field.isRequired,
          metadata: field.metadata,
          value: widget.formData[field.fieldName] as bool?,
          onChanged: _handleFieldChange,
        );

      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Unsupported field type: ${field.fieldType}',
            style: const TextStyle(color: Colors.red),
          ),
        );
    }
  }

  List<DropdownOption> _parseDropdownOptions(Map<String, dynamic>? options) {
    if (options == null || options['options'] == null) return [];
    
    final optionsList = options['options'] as List<dynamic>;
    return optionsList.map((option) {
      return DropdownOption(
        value: option['value']?.toString() ?? '',
        label: option['label']?.toString() ?? '',
      );
    }).toList();
  }

  List<Map<String, dynamic>> _parseOptions(Map<String, dynamic>? options) {
    if (options == null || options['options'] == null) return [];
    
    final optionsList = options['options'] as List<dynamic>;
    return optionsList.map((option) {
      return {
        'value': option['value']?.toString() ?? '',
        'label': option['label']?.toString() ?? '',
      };
    }).toList();
  }

  void _handleFieldChange(String fieldName, dynamic value) {
    if (widget.onFieldChanged != null) {
      widget.onFieldChanged!(fieldName, value);
    }
  }

  String? _validateField(DynamicFormFieldModel field, String? value) {
    if (field.isRequired && (value == null || value.isEmpty)) {
      return 'This field is required';
    }

    final rules = field.validationRules;
    if (rules != null && value != null && value.isNotEmpty) {
      // Min length validation
      if (rules['minLength'] != null && value.length < rules['minLength']) {
        return 'Minimum length is ${rules['minLength']} characters';
      }

      // Max length validation
      if (rules['maxLength'] != null && value.length > rules['maxLength']) {
        return 'Maximum length is ${rules['maxLength']} characters';
      }

      // Pattern validation
      if (rules['pattern'] != null) {
        final regex = RegExp(rules['pattern']);
        if (!regex.hasMatch(value)) {
          return rules['patternMessage'] ?? 'Invalid format';
        }
      }
    }

    return null;
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }
}
