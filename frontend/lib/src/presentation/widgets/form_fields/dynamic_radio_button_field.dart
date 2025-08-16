import 'package:flutter/material.dart';

class DynamicRadioButtonField extends StatelessWidget {
  final String label;
  final String? value;
  final List<Map<String, dynamic>> options;
  final Function(String?)? onChanged;
  final bool isRequired;
  final String? Function(String?)? validator;
  final String? helpText;

  const DynamicRadioButtonField({
    Key? key,
    required this.label,
    this.value,
    required this.options,
    this.onChanged,
    this.isRequired = false,
    this.validator,
    this.helpText,
  }) : super(key: key);

  String? _defaultValidator(String? value) {
    if (isRequired && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: value,
      validator: validator ?? _defaultValidator,
      builder: (FormFieldState<String> state) {
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
            if (helpText != null) ...[
              const SizedBox(height: 4),
              Text(
                helpText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: state.hasError ? const Color(0xFFE53E3E) : const Color(0xFFE0E0E0),
                ),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: options.map((option) {
                  final optionValue = option['value']?.toString() ?? '';
                  final optionLabel = option['label']?.toString() ?? '';
                  
                  return RadioListTile<String>(
                    title: Text(
                      optionLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF333333),
                      ),
                    ),
                    value: optionValue,
                    groupValue: state.value,
                    onChanged: (String? selectedValue) {
                      state.didChange(selectedValue);
                      if (onChanged != null) {
                        onChanged!(selectedValue);
                      }
                    },
                    activeColor: const Color(0xFF2196F3),
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 12),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: Color(0xFFE53E3E),
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
