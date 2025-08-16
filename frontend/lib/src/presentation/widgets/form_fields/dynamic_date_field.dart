import 'package:flutter/material.dart';

class DynamicDateField extends StatefulWidget {
  final String label;
  final String? placeholder;
  final String? value;
  final Function(String?)? onChanged;
  final bool isRequired;
  final String? Function(String?)? validator;
  final String? helpText;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DynamicDateField({
    Key? key,
    required this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.validator,
    this.helpText,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  @override
  State<DynamicDateField> createState() => _DynamicDateFieldState();
}

class _DynamicDateFieldState extends State<DynamicDateField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.value ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _defaultValidator(String? value) {
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    if (value != null && value.isNotEmpty) {
      try {
        DateTime.parse(value);
      } catch (e) {
        return 'Please enter a valid date';
      }
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate;
    
    if (_controller.text.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(_controller.text);
      } catch (e) {
        selectedDate = DateTime.now();
      }
    } else {
      selectedDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF2196F3),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = picked.toIso8601String().split('T')[0];
      _controller.text = formattedDate;
      if (widget.onChanged != null) {
        widget.onChanged!(formattedDate);
      }
    }
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
              TextSpan(text: widget.label),
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFE53E3E)),
                ),
            ],
          ),
        ),
        if (widget.helpText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helpText!,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
          ),
        ],
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          validator: widget.validator ?? _defaultValidator,
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            hintText: widget.placeholder ?? 'Select date',
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
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }
}
