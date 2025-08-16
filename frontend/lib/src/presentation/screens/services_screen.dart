import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/utils/department_utils.dart';
import '../widgets/bottom_navigation_widget.dart';

class ServicesScreen extends StatefulWidget {
  static const String routeName = '/services';

  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DepartmentItem> filteredDepartments = [];

  @override
  void initState() {
    super.initState();
    _updateFilteredDepartments();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _updateFilteredDepartments();
  }

  void _updateFilteredDepartments() {
    setState(() {
      final departments = DepartmentUtils.allDepartments;
      
      if (_searchController.text.isEmpty) {
        filteredDepartments = departments;
      } else {
        final query = _searchController.text.toLowerCase();
        filteredDepartments = departments.where((department) {
          return department.name.toLowerCase().contains(query) ||
                 department.description.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styles = TextStyleHelper.instance;
    final theme = Theme.of(context);

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
          'Departments & Services',
          style: styles.title18Medium.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to notifications
            },
            icon: Icon(
              Remix.notification_line,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          IconButton(
            onPressed: () {
              // Navigate to profile
            },
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: theme.colorScheme.onPrimary,
              child: Icon(Remix.user_line, size: 18, color: theme.primaryColor),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Government Departments',
                  style: styles.headline24.copyWith(
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a department to view their available services\nand submit applications online',
                  style: styles.body14Regular.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 16),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a department',
                      hintStyle: styles.body14Regular.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      prefixIcon: Icon(
                        Remix.search_line,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Departments Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: filteredDepartments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Remix.search_line,
                            size: 48,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No departments found',
                            style: styles.body16Medium.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search terms',
                            style: styles.body14Regular.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio:
                            0.85, // Increased height to prevent overflow
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredDepartments.length,
                      itemBuilder: (context, index) {
                        final department = filteredDepartments[index];
                        return _buildDepartmentCard(department, theme, styles);
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentItem: BottomNavItem.services,
      ),
    );
  }

  Widget _buildDepartmentCard(
    DepartmentItem department,
    ThemeData theme,
    TextStyleHelper styles,
  ) {
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
                // const Spacer(),
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 8,
                //     vertical: 4,
                //   ),
                //   decoration: BoxDecoration(
                //     color: department.color.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Text(
                //     '${department.serviceCount} services',
                //     style: styles.body10Regular.copyWith(
                //       color: department.color,
                //     ),
                //   ),
                // ),
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
            Text(
              department.description,
              style: styles.body12Regular.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
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
