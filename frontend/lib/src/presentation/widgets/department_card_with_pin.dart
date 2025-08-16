import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/utils/department_utils.dart';

class DepartmentCardWithPin extends StatelessWidget {
  final DepartmentItem department;

  const DepartmentCardWithPin({Key? key, required this.department})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final theme = Theme.of(context);

    return Consumer<DepartmentsService>(
      builder: (context, departmentsService, child) {
        final isPinned = departmentsService.isDepartmentPinned(department.id);

        return GestureDetector(
          onTap: () {
            // Navigate to department services (form selection)
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
                    GestureDetector(
                      onTap: () {
                        departmentsService.toggleDepartmentPin(department.id);
                        final action = isPinned ? 'unpinned' : 'pinned';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${department.name} $action'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: department.color,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isPinned
                              ? department.color.withOpacity(0.1)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isPinned
                                ? department.color
                                : theme.dividerTheme.color!.withOpacity(0.5),
                          ),
                        ),
                        child: Icon(
                          isPinned ? Remix.pushpin_fill : Remix.pushpin_line,
                          size: 14,
                          color: isPinned
                              ? department.color
                              : theme.colorScheme.onSurface.withOpacity(0.6),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'View Services',
                      style: styles.body12Medium.copyWith(
                        color: department.color,
                      ),
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
      },
    );
  }
}
