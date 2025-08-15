import 'package:flutter/material.dart';
import 'package:gov_connect/src/core/models/dynamic_form_models.dart';
import 'package:gov_connect/src/presentation/widgets/dynamic_form_renderer.dart';

class ServiceOverviewScreen extends StatefulWidget {
  final DynamicFormModel form;
  static const String routeName = '/service-overview';

  const ServiceOverviewScreen({
    Key? key,
    required this.form,
  }) : super(key: key);

  @override
  State<ServiceOverviewScreen> createState() => _ServiceOverviewScreenState();
}

class _ServiceOverviewScreenState extends State<ServiceOverviewScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _formData = {};
  int _currentPage = 1;

  void _handleFieldChange(String fieldName, dynamic value) {
    setState(() {
      _formData[fieldName] = value;
    });
  }

  void _proceedToForm() {
    // Validate any required dependency forms are completed
    bool canProceed = true;
    String missingForms = '';

    final overviewSection = widget.form.sections.firstWhere(
      (section) => section.pageNumber == 1,
      orElse: () => widget.form.sections.first,
    );

    for (final field in overviewSection.fields) {
      if (field.fieldType == DynamicFieldType.dependencyForm && field.isRequired) {
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

    // Proceed to the actual form (next page)
    setState(() {
      _currentPage = 2;
    });
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

  void _nextPage() {
    if (_currentPage < widget.form.totalPages) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverviewPage = _currentPage == 1;
    final overviewSection = widget.form.sections.firstWhere(
      (section) => section.pageNumber == 1,
      orElse: () => widget.form.sections.first,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentPage > 1) {
              _previousPage();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          isOverviewPage ? 'Service Overview' : widget.form.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header section with title and description
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
                  // Service title and description (always shown)
                  Text(
                    widget.form.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.form.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.form.description!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  // Progress indicator (only show if not on overview page)
                  if (!isOverviewPage && widget.form.totalPages > 1) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: List.generate(widget.form.totalPages, (index) {
                        final pageNum = index + 1;
                        final isActive = pageNum == _currentPage;
                        final isCompleted = pageNum < _currentPage;
                        
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: index < widget.form.totalPages - 1 ? 8 : 0,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: isActive || isCompleted 
                                      ? Colors.white 
                                      : Colors.white30,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: pageNum == 1 
                                      ? Icon(
                                          Icons.info_outline,
                                          color: isActive 
                                            ? const Color(0xFF2196F3)
                                            : Colors.white30,
                                          size: 16,
                                        )
                                      : isCompleted
                                        ? const Icon(
                                            Icons.check,
                                            color: Color(0xFF2196F3),
                                            size: 18,
                                          )
                                        : Text(
                                            (pageNum - 1).toString(),
                                            style: TextStyle(
                                              color: isActive 
                                                ? const Color(0xFF2196F3)
                                                : Colors.white30,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                  ),
                                ),
                                if (index < widget.form.totalPages - 1)
                                  Expanded(
                                    child: Container(
                                      height: 2,
                                      color: isCompleted ? Colors.white : Colors.white30,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isOverviewPage 
                        ? 'Overview' 
                        : 'Step ${_currentPage - 1} of ${widget.form.totalPages - 1}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  
                  // Overview page description
                  if (isOverviewPage) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Please complete the required forms below before proceeding with your application.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isOverviewPage) ...[
                    // Auto-filled data section for overview page
                    _buildAutoFilledDataSection(overviewSection),
                  ] else ...[
                    // Regular form renderer for other pages
                    DynamicFormRenderer(
                      form: widget.form,
                      currentPage: _currentPage,
                      formData: _formData,
                      formKey: _formKey,
                      onFieldChanged: _handleFieldChange,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Bottom navigation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: Row(
              children: [
                if (_currentPage > 1)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2196F3),
                        side: const BorderSide(color: Color(0xFF2196F3)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                
                if (_currentPage > 1) const SizedBox(width: 16),
                
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isOverviewPage ? _proceedToForm : (
                      _currentPage < widget.form.totalPages ? _nextPage : null
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isOverviewPage 
                        ? 'Proceed to Application'
                        : (_currentPage < widget.form.totalPages ? 'Next' : 'Submit'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoFilledDataSection(DynamicFormSectionModel section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFF2196F3),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  if (section.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      section.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Fields
        Column(
          children: section.fields.map((field) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: DynamicFormRenderer(
                form: widget.form,
                currentPage: 1,
                formData: _formData,
                formKey: _formKey,
                onFieldChanged: _handleFieldChange,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
