import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gov_connect/src/core/config/api_config.dart';
import 'package:gov_connect/src/core/services/auth_service.dart';

class FormApiService {
  final AuthService _authService;
  static const String baseUrl = ApiConfig.baseUrl;

  FormApiService(this._authService);

  /// Test API connectivity
  Future<bool> testConnection() async {
    try {
      print('🔄 Testing API connectivity...');
      final url = Uri.parse('$baseUrl/dynamic-forms');
      print('🌐 Testing connection to: $url');
      
      final response = await http.get(url);
      print('📡 Connection test response: ${response.statusCode}');
      print('📡 Connection test body: ${response.body}');
      
      // 401 means API is reachable but needs auth, 200 means success
      return response.statusCode == 401 || response.statusCode == 200;
    } catch (e) {
      print('💥 Connection test failed: $e');
      return false;
    }
  }

  /// Fetches form configuration by ID
  Future<Map<String, dynamic>?> getFormConfig(String formId) async {
    try {
      print('🔄 Attempting to fetch form config for ID: $formId');
      
      // Use the correct endpoint from Postman collection: /dynamic-forms/{formId}
    final url = Uri.parse('$baseUrl/dynamic-forms/$formId');
    final token = await _authService.getToken();
      print('🌐 Making request to: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Successfully parsed form config');
        return data as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        print('❌ Form not found (404)');
        throw Exception('Form not found');
      } else {
        print('❌ Request failed with status: ${response.statusCode}');
        throw Exception('Failed to fetch form: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Error fetching form config: $e');
      return null;
    }
  }

  /// Fetches multiple form configurations by IDs
  Future<List<Map<String, dynamic>>> getFormConfigs(List<String> formIds) async {
    final List<Map<String, dynamic>> forms = [];
    
    for (String formId in formIds) {
      final formConfig = await getFormConfig(formId);
      if (formConfig != null) {
        forms.add(formConfig);
      }
    }
    
    return forms;
  }

  /// Seeds sample forms (for development/testing)
  Future<bool> seedSampleForms() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final url = Uri.parse('$baseUrl/dynamic-forms/seed-sample');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error seeding sample forms: $e');
      return false;
    }
  }
}
