import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/utils/department_utils.dart';

class PinnedDepartmentCard extends StatelessWidget {
  final DepartmentItem department;
  final bool showPinButton;

  const PinnedDepartmentCard({
    Key? key,
    required this.department,
    this.showPinButton = true,
  }) : super(key: key);

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
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerTheme.color!.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: department.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    department.icon,
                    color: department.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        department.name,
                        style: styles.title16Medium.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${department.serviceCount} services available',
                        style: styles.body14Regular.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (showPinButton)
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
                      padding: const EdgeInsets.all(8),
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
                        size: 16,
                        color: isPinned
                            ? department.color
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
