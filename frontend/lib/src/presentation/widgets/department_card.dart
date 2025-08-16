import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/utils/department_utils.dart';

class DepartmentCard extends StatelessWidget {
  final DepartmentItem department;

  const DepartmentCard({Key? key, required this.department}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // Navigate to department services (form selection)
        print('Tapped on ${department.name}');
        context.pushNamed(
          'form-selection',
          queryParameters: {
            'department': department.name,
            'departmentId': department.id,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: department.color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: department.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    department.icon,
                    size: 20,
                    color: department.color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: department.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${department.serviceCount} services',
                    style: styles.body10Regular.copyWith(
                      color: department.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              department.name,
              style: styles.body14Medium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                department.description,
                style: styles.body12Regular.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'View Services',
                  style: styles.body12Medium.copyWith(color: department.color),
                ),
                const SizedBox(width: 4),
                Icon(
                  Remix.arrow_right_s_line,
                  size: 16,
                  color: department.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
