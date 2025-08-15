import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/api_service.dart';
import '../../../injection.dart';
import '../../../core/models/upload_models.dart';
import '../../widgets/action_button.dart';

class FileUploadField extends StatefulWidget {
  final String label;
  final String? helperText;
  final bool isRequired;
  final String? folder;
  final ValueChanged<UploadResult?>? onUploaded;
  final List<String>?
  allowedMimeTypes; // e.g. ['image/png','image/jpeg','application/pdf']

  const FileUploadField({
    Key? key,
    required this.label,
    this.helperText,
    this.isRequired = false,
    this.folder,
    this.onUploaded,
    this.allowedMimeTypes,
  }) : super(key: key);

  @override
  State<FileUploadField> createState() => _FileUploadFieldState();
}

class _FileUploadFieldState extends State<FileUploadField> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;
  bool _isUploading = false;
  UploadResult? _result;
  String? _error;

  Future<void> _pickImage() async {
    setState(() => _error = null);
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() => _pickedFile = file);
      }
    } catch (e) {
      setState(() => _error = 'Failed to pick file');
    }
  }

  Future<void> _upload(ApiService api) async {
    if (_pickedFile == null) {
      setState(() => _error = 'Please select a file');
      return;
    }
    // Enforce allowed MIME types if provided
    final contentType = _inferContentType(_pickedFile!.path);
    if (widget.allowedMimeTypes != null &&
        contentType != null &&
        !widget.allowedMimeTypes!.contains(contentType)) {
      setState(() => _error = 'Unsupported file type');
      return;
    }
    setState(() {
      _isUploading = true;
      _error = null;
    });
    try {
      final res = await api.uploadFile(
        _pickedFile!.path,
        folder: widget.folder,
        contentType: contentType,
        fileName: _pickedFile!.name,
      );
      setState(() => _result = res);
      widget.onUploaded?.call(res);
    } catch (e) {
      setState(() => _error = e.toString());
      widget.onUploaded?.call(null);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  String? _inferContentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.pdf')) return 'application/pdf';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final api = ServiceLocator().apiService;
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
        if (widget.helperText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.helperText!,
            style: const TextStyle(color: Color(0xFF737373), fontSize: 14),
          ),
        ],
        const SizedBox(height: 12),

        // Preview card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _thumb(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pickedFile?.name ?? (_result?.key ?? 'No file selected'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF171717),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _result?.url ?? 'Supported: PNG, JPG, PDF',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF737373),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (_isUploading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF737373)),
                  onPressed: () => setState(() {
                    _pickedFile = null;
                    _result = null;
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Actions
        Row(
          children: [
            Expanded(
              child: ActionButton(
                text: _pickedFile == null ? 'Choose File' : 'Change File',
                icon: Icons.attach_file,
                onPressed: _pickImage,
                isPrimary: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ActionButton(
                text: _result == null ? 'Upload' : 'Reupload',
                icon: Icons.cloud_upload_outlined,
                onPressed: _isUploading ? () {} : () => _upload(api),
                isPrimary: true,
              ),
            ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _thumb() {
    if (_pickedFile != null) {
      final isImage =
          _pickedFile!.path.toLowerCase().endsWith('.png') ||
          _pickedFile!.path.toLowerCase().endsWith('.jpg') ||
          _pickedFile!.path.toLowerCase().endsWith('.jpeg');
      if (isImage) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(File(_pickedFile!.path), fit: BoxFit.cover),
        );
      }
    }
    return const Icon(Icons.insert_drive_file, color: Color(0xFF737373));
  }
}
