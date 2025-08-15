import 'package:flutter/material.dart';

class EmailInputField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String? value;
  final Function(String?)? onChanged;
  final bool isRequired;
  final String? Function(String?)? validator;

  const EmailInputField({
    Key? key,
    required this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.validator,
  }) : super(key: key);

  String? _defaultEmailValidator(String? value) {
    if (isRequired && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    if (value != null && value.isNotEmpty) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
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
          validator: validator ?? _defaultEmailValidator,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: placeholder ?? 'Enter email address',
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
              Icons.email_outlined,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }
}
