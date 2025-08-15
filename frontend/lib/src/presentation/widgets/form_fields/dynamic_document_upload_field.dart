import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class DynamicDocumentUploadField extends StatefulWidget {
  final String label;
  final List<String>? value;
  final Function(List<String>?)? onChanged;
  final bool isRequired;
  final String? Function(List<String>?)? validator;
  final String? helpText;
  final List<String>? allowedExtensions;
  final int maxFiles;
  final int? maxFileSizeMB;

  const DynamicDocumentUploadField({
    Key? key,
    required this.label,
    this.value,
    this.onChanged,
    this.isRequired = false,
    this.validator,
    this.helpText,
    this.allowedExtensions,
    this.maxFiles = 5,
    this.maxFileSizeMB,
  }) : super(key: key);

  @override
  State<DynamicDocumentUploadField> createState() => _DynamicDocumentUploadFieldState();
}

class _DynamicDocumentUploadFieldState extends State<DynamicDocumentUploadField> {
  List<String> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _selectedFiles = List.from(widget.value ?? []);
  }

  String? _defaultValidator(List<String>? value) {
    if (widget.isRequired && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: widget.maxFiles > 1,
        type: widget.allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: widget.allowedExtensions,
      );

      if (result != null) {
        List<String> newFiles = [];
        
        for (PlatformFile file in result.files) {
          // Check file size if limit is set
          if (widget.maxFileSizeMB != null && file.size > widget.maxFileSizeMB! * 1024 * 1024) {
            _showErrorDialog('File ${file.name} exceeds size limit of ${widget.maxFileSizeMB}MB');
            continue;
          }
          
          if (file.path != null) {
            newFiles.add(file.path!);
          }
        }
        
        // Check if total files exceed limit
        List<String> updatedFiles = List.from(_selectedFiles);
        for (String newFile in newFiles) {
          if (updatedFiles.length < widget.maxFiles && !updatedFiles.contains(newFile)) {
            updatedFiles.add(newFile);
          }
        }
        
        setState(() {
          _selectedFiles = updatedFiles;
        });
        
        if (widget.onChanged != null) {
          widget.onChanged!(_selectedFiles);
        }
      }
    } catch (e) {
      _showErrorDialog('Error picking files: ${e.toString()}');
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    
    if (widget.onChanged != null) {
      widget.onChanged!(_selectedFiles);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  String _getFileSize(String filePath) {
    try {
      final file = File(filePath);
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown size';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      initialValue: _selectedFiles,
      validator: (value) => widget.validator?.call(value) ?? _defaultValidator(value),
      builder: (FormFieldState<List<String>> state) {
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
            
            // Upload button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _selectedFiles.length < widget.maxFiles ? _pickFiles : null,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  _selectedFiles.isEmpty 
                    ? 'Upload files' 
                    : 'Add more files (${_selectedFiles.length}/${widget.maxFiles})',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2196F3),
                  side: BorderSide(
                    color: state.hasError ? const Color(0xFFE53E3E) : const Color(0xFF2196F3),
                  ),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            
            // File list
            if (_selectedFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _selectedFiles.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final filePath = _selectedFiles[index];
                    final fileName = _getFileName(filePath);
                    final fileSize = _getFileSize(filePath);
                    
                    return ListTile(
                      leading: const Icon(
                        Icons.insert_drive_file_outlined,
                        color: Color(0xFF2196F3),
                      ),
                      title: Text(
                        fileName,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        fileSize,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFFE53E3E)),
                        onPressed: () => _removeFile(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    );
                  },
                ),
              ),
            ],
            
            // File constraints info
            if (widget.allowedExtensions != null || widget.maxFileSizeMB != null) ...[
              const SizedBox(height: 8),
              Text(
                [
                  if (widget.allowedExtensions != null) 
                    'Allowed: ${widget.allowedExtensions!.join(', ')}',
                  if (widget.maxFileSizeMB != null) 
                    'Max size: ${widget.maxFileSizeMB}MB per file',
                ].join(' • '),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF666666),
                ),
              ),
            ],
            
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
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
