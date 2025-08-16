import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TelephoneInputField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String? value;
  final Function(String?)? onChanged;
  final bool isRequired;
  final String? Function(String?)? validator;

  const TelephoneInputField({
    Key? key,
    required this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.validator,
  }) : super(key: key);

  String? _defaultTelephoneValidator(String? value) {
    if (isRequired && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    if (value != null && value.isNotEmpty) {
      // Remove spaces and dashes for validation
      final cleanedValue = value.replaceAll(RegExp(r'[\s-]'), '');
      // Sri Lankan telephone numbers are typically 10 digits (including area code)
      if (cleanedValue.length < 9 || cleanedValue.length > 10) {
        return 'Please enter a valid telephone number';
      }
      // Check if it contains only digits
      if (!RegExp(r'^\d+$').hasMatch(cleanedValue)) {
        return 'Telephone number should contain only digits';
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
            children: [
              TextSpan(text: label),
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFE53E3E)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          validator: validator ?? _defaultTelephoneValidator,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\s-]')),
            LengthLimitingTextInputFormatter(12), // Allow for formatting
          ],
          decoration: InputDecoration(
            hintText: placeholder ?? '011-2345678',
            hintStyle: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE53E3E)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
            fillColor: Colors.white,
            filled: true,
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }
}
