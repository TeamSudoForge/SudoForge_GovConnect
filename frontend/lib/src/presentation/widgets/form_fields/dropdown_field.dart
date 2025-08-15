import 'package:flutter/material.dart';

class DropdownField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String? value;
  final List<DropdownOption> options;
  final Function(String?)? onChanged;
  final bool isRequired;

  const DropdownField({
    Key? key,
    required this.label,
    this.placeholder,
    this.value,
    required this.options,
    this.onChanged,
    this.isRequired = false,
  }) : super(key: key);

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
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: placeholder,
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
            contentPadding: const EdgeInsets.all(16),
            fillColor: Colors.white,
            filled: true,
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option.value,
              child: Text(
                option.label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
            );
          }).toList(),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }
}

class DropdownOption {
  final String value;
  final String label;

  const DropdownOption({
    required this.value,
    required this.label,
  });
}
