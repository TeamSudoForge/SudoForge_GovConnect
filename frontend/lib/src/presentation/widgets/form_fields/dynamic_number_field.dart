import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicNumberField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final String? value;
  final Function(String?)? onChanged;
  final bool isRequired;
  final String? Function(String?)? validator;
  final String? helpText;
  final bool allowDecimals;
  final double? minValue;
  final double? maxValue;

  const DynamicNumberField({
    Key? key,
    required this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.validator,
    this.helpText,
    this.allowDecimals = true,
    this.minValue,
    this.maxValue,
  }) : super(key: key);

  String? _defaultValidator(String? value) {
    if (isRequired && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    
    if (value != null && value.isNotEmpty) {
      final numValue = double.tryParse(value);
      if (numValue == null) {
        return 'Please enter a valid number';
      }
      
      if (minValue != null && numValue < minValue!) {
        return 'Value must be at least $minValue';
      }
      
      if (maxValue != null && numValue > maxValue!) {
        return 'Value must not exceed $maxValue';
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
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          validator: validator ?? _defaultValidator,
          keyboardType: TextInputType.numberWithOptions(decimal: allowDecimals),
          inputFormatters: [
            if (allowDecimals)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: placeholder ?? 'Enter number',
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
              Icons.numbers_outlined,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }
}
