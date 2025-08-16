import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dynamic_form_models.dart';
import '../config/api_config.dart';
import '../services/auth_service.dart';

class DynamicFormsService {
  static const String _baseUrl = '${ApiConfig.baseUrl}/dynamic-forms';

  final AuthService _authService;

  DynamicFormsService({required AuthService authService}) : _authService = authService;

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<DynamicFormModel>> getAllForms() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((form) => DynamicFormModel.fromJson(form)).toList();
      } else {
        throw Exception('Failed to fetch forms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching forms: $e');
    }
  }

  Future<DynamicFormModel> getFormById(String formId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/$formId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DynamicFormModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch form: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching form: $e');
    }
  }

  Future<List<DynamicFormSectionModel>> getFormPage(String formId, int pageNumber) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/$formId/page/$pageNumber'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((section) => DynamicFormSectionModel.fromJson(section)).toList();
      } else {
        throw Exception('Failed to fetch form page: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching form page: $e');
    }
  }

  Future<List<String>> getFieldTypes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/field-types'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['fieldTypes']);
      } else {
        throw Exception('Failed to fetch field types: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching field types: $e');
    }
  }

  Future<FormSubmissionModel> createSubmission({
    required String formId,
    required Map<String, dynamic> submissionData,
    String status = 'draft',
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'formId': formId,
        'submissionData': submissionData,
        'status': status,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/submissions'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return FormSubmissionModel.fromJson(data);
      } else {
        throw Exception('Failed to create submission: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating submission: $e');
    }
  }

  Future<FormSubmissionModel> updateSubmission({
    required String submissionId,
    Map<String, dynamic>? submissionData,
    String? status,
    String? reviewNotes,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};
      
      if (submissionData != null) body['submissionData'] = submissionData;
      if (status != null) body['status'] = status;
      if (reviewNotes != null) body['reviewNotes'] = reviewNotes;

      final response = await http.put(
        Uri.parse('$_baseUrl/submissions/$submissionId'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FormSubmissionModel.fromJson(data);
      } else {
        throw Exception('Failed to update submission: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating submission: $e');
    }
  }

  Future<List<FormSubmissionModel>> getUserSubmissions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/submissions/my'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((submission) => FormSubmissionModel.fromJson(submission)).toList();
      } else {
        throw Exception('Failed to fetch submissions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching submissions: $e');
    }
  }

  Future<FormSubmissionModel> getSubmissionById(String submissionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/submissions/$submissionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return FormSubmissionModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch submission: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching submission: $e');
    }
  }
}

// Form Submission Model
class FormSubmissionModel {
  final String id;
  final String userId;
  final String formId;
  final Map<String, dynamic> submissionData;
  final String status;
  final String? reviewNotes;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DynamicFormModel? form;

  FormSubmissionModel({
    required this.id,
    required this.userId,
    required this.formId,
    required this.submissionData,
    required this.status,
    this.reviewNotes,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
    this.form,
  });

  factory FormSubmissionModel.fromJson(Map<String, dynamic> json) {
    return FormSubmissionModel(
      id: json['id'],
      userId: json['userId'],
      formId: json['formId'],
      submissionData: json['submissionData'],
      status: json['status'],
      reviewNotes: json['reviewNotes'],
      reviewedBy: json['reviewedBy'],
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      form: json['form'] != null ? DynamicFormModel.fromJson(json['form']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'formId': formId,
      'submissionData': submissionData,
      'status': status,
      'reviewNotes': reviewNotes,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'form': form?.toJson(),
    };
  }
}
