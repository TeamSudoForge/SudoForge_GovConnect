import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import '../forms/demo_form_screen.dart';

class JsonFormTestScreen extends StatefulWidget {
  static const String routeName = '/json-form-test';
  
  @override
  _JsonFormTestScreenState createState() => _JsonFormTestScreenState();
}

class _JsonFormTestScreenState extends State<JsonFormTestScreen> {
  Map<String, dynamic>? jsonData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/sample_form_config.json');
      setState(() {
        jsonData = json.decode(jsonString);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Failed to load JSON: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON-Driven Form Test'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : error != null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(error!, style: TextStyle(color: Colors.red)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadJsonData,
                  child: Text('Retry'),
                ),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Form Configuration Loaded',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Form ID: ${jsonData?['id']}'),
                        Text('Title: ${jsonData?['title']}'),
                        Text('Sections: ${jsonData?['sections']?.length ?? 0}'),
                        Text('Version: ${jsonData?['version']}'),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Form Sections Preview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...((jsonData?['sections'] as List?) ?? []).map((section) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text('Page ${section['pageNumber']}: '),
                                Expanded(child: Text(section['title'] ?? 'Unknown')),
                                Text('(${section['fields']?.length ?? 0} fields)'),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DemoFormScreen(jsonFormData: jsonData),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Launch JSON-Driven Form',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DemoFormScreen(), // Uses default sample data
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF2196F3)),
                  ),
                  child: Text('Launch Form with Default Data'),
                ),
                
                SizedBox(height: 24),
                
                ExpansionTile(
                  title: Text('View Raw JSON Data'),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SelectableText(
                        JsonEncoder.withIndent('  ').convert(jsonData),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
