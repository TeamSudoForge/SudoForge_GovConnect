import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DependencyFormField extends StatefulWidget {
  final String label;
  final String fieldName;
  final String? helpText;
  final bool isRequired;
  final Map<String, dynamic>? metadata;
  final Function(String fieldName, dynamic value) onChanged;
  final bool? value; // boolean indicating if form is filled

  const DependencyFormField({
    Key? key,
    required this.label,
    required this.fieldName,
    this.helpText,
    this.isRequired = false,
    this.metadata,
    required this.onChanged,
    this.value,
  }) : super(key: key);

  @override
  State<DependencyFormField> createState() => _DependencyFormFieldState();
}

class _DependencyFormFieldState extends State<DependencyFormField> {
  bool _isExpanded = false;
  
  bool get isFilled => widget.value ?? false;
  String? get formUrl => widget.metadata?['formUrl'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Main header row
          Row(
            children: [
              // Status icon
              Icon(
                isFilled ? Icons.check : Icons.schedule,
                color: isFilled ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                size: 20,
              ),
              const SizedBox(width: 12),
              
              // Label and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    if (widget.helpText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.helpText!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Expand/collapse icon
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF666666),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          
          // Expandable content
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE0E0E0)),
            const SizedBox(height: 16),
            
            // Action button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: formUrl != null ? () => _navigateToForm() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFilled 
                    ? const Color(0xFF4CAF50) 
                    : const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isFilled ? 'Resubmit Form' : 'Continue to Form',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            // Status info
            if (isFilled) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: const Color(0xFF4CAF50),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'This form has been completed successfully.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _navigateToForm() {
    if (formUrl == null) return;
    
    // Handle different URL formats
    if (formUrl!.startsWith('/')) {
      // Internal route
      context.push(formUrl!);
    } else {
      // External URL - could implement web view or external launch
      // For now, let's assume it's an internal route
      context.push('/$formUrl');
    }
    
    // Mark as filled after navigation (in a real app, this would be handled by the form completion)
    // For demo purposes, we'll mark it as filled after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onChanged(widget.fieldName, true);
      }
    });
  }
}
