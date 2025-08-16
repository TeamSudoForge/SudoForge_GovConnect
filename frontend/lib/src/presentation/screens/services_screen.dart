import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/utils/department_utils.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../widgets/department_card_with_pin.dart';

class ServicesScreen extends StatefulWidget {
  static const String routeName = '/services';

  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DepartmentItem> filteredDepartments = [];
  bool _isSearchVisible = false;

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
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                }
              });
            },
            icon: Icon(
              _isSearchVisible ? Remix.close_line : Remix.search_line,
              color: theme.colorScheme.onPrimary,
            ),
          ),
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
                // Search Bar - conditionally visible
                if (_isSearchVisible) ...[
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
                      autofocus: true,
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
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
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
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search terms',
                            style: styles.body14Regular.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Consumer<DepartmentsService>(
                      builder: (context, departmentsService, child) {
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio:
                                    0.9, // Adjusted for better spacing
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: filteredDepartments.length,
                          itemBuilder: (context, index) {
                            final department = filteredDepartments[index];
                            return DepartmentCardWithPin(
                              department: department,
                            );
                          },
                        );
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
}
