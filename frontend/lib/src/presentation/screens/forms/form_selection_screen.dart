import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../../core/app_export.dart';
import '../../widgets/bottom_navigation_widget.dart';

class FormSelectionScreen extends StatelessWidget {
  static const String routeName = '/form-selection';

  final String? department;
  final String? departmentId;

  const FormSelectionScreen({Key? key, this.department, this.departmentId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final theme = Theme.of(context);

    // Get department-specific forms
    final departmentForms = _getDepartmentForms(department ?? 'Immigration');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Remix.arrow_left_line, color: theme.colorScheme.onPrimary),
        ),
        title: Text(
          '${department ?? 'Department'} Services',
          style: styles.title18Medium.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${department ?? "Immigration"} Services',
                    style: styles.headline24.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a service form from the ${department ?? "Immigration"} department',
                    style: styles.body14Regular.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Forms List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  itemCount: departmentForms.length,
                  itemBuilder: (context, index) {
                    final form = departmentForms[index];
                    return _buildFormCard(context, form, theme, styles);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentItem: BottomNavItem.services,
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    Map<String, String> form,
    ThemeData theme,
    TextStyleHelper styles,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openForm(context, form['id']!),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getFormIcon(form['title']!),
                      color: theme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          form['title']!,
                          style: styles.title16Medium.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          form['description']!,
                          style: styles.body14Regular.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Remix.arrow_right_s_line,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Apply Now',
                  style: styles.body12Medium.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFormIcon(String title) {
    if (title.toLowerCase().contains('id') ||
        title.toLowerCase().contains('recovery')) {
      return Remix.id_card_line;
    } else if (title.toLowerCase().contains('business') ||
        title.toLowerCase().contains('license')) {
      return Remix.briefcase_line;
    } else if (title.toLowerCase().contains('health')) {
      return Remix.health_book_line;
    } else if (title.toLowerCase().contains('building') ||
        title.toLowerCase().contains('permit')) {
      return Remix.building_line;
    } else if (title.toLowerCase().contains('passport')) {
      return Remix.passport_line;
    } else if (title.toLowerCase().contains('food')) {
      return Remix.restaurant_line;
    } else if (title.toLowerCase().contains('trade')) {
      return Remix.store_line;
    } else if (title.toLowerCase().contains('zoning')) {
      return Remix.map_line;
    }
    return Remix.file_text_line;
  }

  List<Map<String, String>> _getDepartmentForms(String department) {
    switch (department.toLowerCase()) {
      case 'immigration':
        return [
          {
            'id': 'fa79a916-e02d-4e41-888f-ccbd7af664b4',
            'title': 'ID Recovery Application',
            'description':
                'Apply for replacement of lost or damaged identity documents',
          },
          {
            'id': '8f65c305-8c2a-4346-bc20-7c727ddb911c',
            'title': 'Passport Application',
            'description': 'Apply for new passport or passport renewal',
          },
        ];
      case 'business services':
        return [
          {
            'id': 'fa79a916-e02d-4e41-888f-ccbd7af664b4',
            'title': 'Business License Application',
            'description':
                'Register a new business and obtain required licenses',
          },
          {
            'id': '8f65c305-8c2a-4346-bc20-7c727ddb911c',
            'title': 'Trade Permit',
            'description':
                'Apply for permits to conduct specific trade activities',
          },
        ];
      case 'health services':
        return [
          {
            'id': 'fa79a916-e02d-4e41-888f-ccbd7af664b4',
            'title': 'Food Handler Permit',
            'description': 'Obtain certification for food service operations',
          },
          {
            'id': '8f65c305-8c2a-4346-bc20-7c727ddb911c',
            'title': 'Health Certificate',
            'description': 'Apply for medical fitness certificates',
          },
        ];
      case 'planning & development':
        return [
          {
            'id': 'fa79a916-e02d-4e41-888f-ccbd7af664b4',
            'title': 'Building Permit',
            'description': 'Apply for construction and renovation permits',
          },
          {
            'id': '8f65c305-8c2a-4346-bc20-7c727ddb911c',
            'title': 'Zoning Application',
            'description': 'Request zoning changes or variances',
          },
        ];
      default:
        return [
          {
            'id': 'fa79a916-e02d-4e41-888f-ccbd7af664b4',
            'title': 'General Application',
            'description': 'General service application form',
          },
        ];
    }
  }

  void _openForm(BuildContext context, String formId) {
    context.pushNamed('demo-form', queryParameters: {'formId': formId});
  }
}
