import 'package:flutter/material.dart';
import 'package:gov_connect/src/core/app_export.dart';
import 'package:gov_connect/src/core/models/dynamic_form_models.dart';
import 'package:gov_connect/src/core/services/dynamic_forms_service.dart';
import 'package:gov_connect/src/presentation/widgets/dynamic_form_renderer.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class DynamicFormScreen extends StatefulWidget {
  final String formId;
  final String? title;

  const DynamicFormScreen({
    Key? key,
    required this.formId,
    this.title,
  }) : super(key: key);

  @override
  State<DynamicFormScreen> createState() => _DynamicFormScreenState();
}

class _DynamicFormScreenState extends State<DynamicFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late DynamicFormsService _dynamicFormsService;
  
  DynamicFormModel? _form;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  
  int _currentPage = 1;
  Map<String, dynamic> _formData = {};
  FormSubmissionModel? _currentSubmission;
  
  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _dynamicFormsService = DynamicFormsService(authService: authService);
    _loadForm();
  }

  Future<void> _loadForm() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final form = await _dynamicFormsService.getFormById(widget.formId);
      
      setState(() {
        _form = form;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDraft() async {
    if (_form == null) return;

    try {
      setState(() => _isSubmitting = true);

      if (_currentSubmission == null) {
        // Create new draft submission
        final submission = await _dynamicFormsService.createSubmission(
          formId: widget.formId,
          submissionData: _formData,
          status: 'draft',
        );
        _currentSubmission = submission;
      } else {
        // Update existing submission
        await _dynamicFormsService.updateSubmission(
          submissionId: _currentSubmission!.id,
          submissionData: _formData,
          status: 'draft',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft saved successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving draft: $e'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitForm() async {
    if (_form == null || !_formKey.currentState!.validate()) return;

    try {
      setState(() => _isSubmitting = true);

      if (_currentSubmission == null) {
        // Create and submit new submission
        await _dynamicFormsService.createSubmission(
          formId: widget.formId,
          submissionData: _formData,
          status: 'submitted',
        );
      } else {
        // Update and submit existing submission
        await _dynamicFormsService.updateSubmission(
          submissionId: _currentSubmission!.id,
          submissionData: _formData,
          status: 'submitted',
        );
      }

      // Navigate to success screen
      context.go('/home/id-recovery-process/success');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: Color(0xFFE53E3E),
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _handleFieldChange(String fieldName, dynamic value) {
    setState(() {
      _formData[fieldName] = value;
    });
  }

  void _nextPage() {
    if (_form != null && _currentPage < _form!.totalPages) {
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title ?? _form?.title ?? 'Dynamic Form',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_form != null && !_isSubmitting)
            TextButton(
              onPressed: _saveDraft,
              child: const Text(
                'Save Draft',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading form',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF666666)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadForm,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_form == null) {
      return const Center(
        child: Text('Form not found'),
      );
    }

    return Column(
      children: [
        // Progress header
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
                // Page indicator
                if (_form!.totalPages > 1) ...[
                  Row(
                    children: List.generate(_form!.totalPages, (index) {
                      final pageNum = index + 1;
                      final isActive = pageNum == _currentPage;
                      final isCompleted = pageNum < _currentPage;
                      
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: index < _form!.totalPages - 1 ? 8 : 0,
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
                                  child: isCompleted
                                    ? const Icon(
                                        Icons.check,
                                        color: Color(0xFF2196F3),
                                        size: 18,
                                      )
                                    : Text(
                                        pageNum.toString(),
                                        style: TextStyle(
                                          color: isActive 
                                            ? const Color(0xFF2196F3)
                                            : Colors.white30,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                ),
                              ),
                              if (index < _form!.totalPages - 1)
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
                  const SizedBox(height: 16),
                ],
                
                // Form title and description
                Text(
                  _form!.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_form!.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _form!.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_form!.totalPages > 1) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Page $_currentPage of ${_form!.totalPages}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
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
            child: DynamicFormRenderer(
              form: _form!,
              currentPage: _currentPage,
              formData: _formData,
              formKey: _formKey,
              onFieldChanged: _handleFieldChange,
            ),
          ),
        ),
        
        // Navigation buttons
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
                    onPressed: _isSubmitting ? null : _previousPage,
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
                  onPressed: _isSubmitting 
                    ? null 
                    : (_currentPage < _form!.totalPages ? _nextPage : _submitForm),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _currentPage < _form!.totalPages ? 'Next' : 'Submit',
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
    );
  }
}
