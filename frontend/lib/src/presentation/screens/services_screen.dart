import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/theme/theme_config.dart';
import '../widgets/bottom_navigation_widget.dart';

class ServicesScreen extends StatefulWidget {
  static const String routeName = '/services';

  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool showAllDepartments = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          icon: Icon(
            Remix.arrow_left_line,
            color: theme.colorScheme.onPrimary,
          ),
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
              child: Icon(
                Remix.user_line,
                size: 18,
                color: theme.primaryColor,
              ),
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
          // Tab Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildTab('Popular', isSelected: !showAllDepartments, onTap: () {
                  setState(() {
                    showAllDepartments = false;
                  });
                }),
                const SizedBox(width: 12),
                _buildTab('All Departments', isSelected: showAllDepartments, onTap: () {
                  setState(() {
                    showAllDepartments = true;
                  });
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Departments Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85, // Increased height to prevent overflow
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: showAllDepartments ? _allDepartments.length : _popularDepartments.length,
                itemBuilder: (context, index) {
                  final department = showAllDepartments ? _allDepartments[index] : _popularDepartments[index];
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

  Widget _buildTab(String text, {bool isSelected = false, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final styles = TextStyleHelper.instance;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: styles.body14Medium.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(DepartmentItem department, ThemeData theme, TextStyleHelper styles) {
    return GestureDetector(
      onTap: () {
        // Navigate to department services (form selection)
        print('Tapped on ${department.name}');
        context.pushNamed('form-selection', queryParameters: {
          'department': department.name,
          'departmentId': department.id,
        });
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
  }
}

class DepartmentItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int serviceCount;

  const DepartmentItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.serviceCount,
  });
}

// Popular Departments Data
final List<DepartmentItem> _popularDepartments = [
  DepartmentItem(
    id: 'immigration',
    name: 'Immigration',
    description: 'Identity documents, passports, and recovery services',
    icon: Remix.passport_line,
    color: const Color(0xFF3B82F6), // Blue
    serviceCount: 5,
  ),
  DepartmentItem(
    id: 'business',
    name: 'Business Services',
    description: 'Licensing, permits, and business registration',
    icon: Remix.briefcase_line,
    color: const Color(0xFF8B5CF6), // Purple
    serviceCount: 8,
  ),
  DepartmentItem(
    id: 'health',
    name: 'Health Services',
    description: 'Public health, permits, and safety services',
    icon: Remix.health_book_line,
    color: const Color(0xFFEF4444), // Red
    serviceCount: 6,
  ),
  DepartmentItem(
    id: 'planning',
    name: 'Planning & Development',
    description: 'Building permits, zoning, and development',
    icon: Remix.building_line,
    color: const Color(0xFFF97316), // Orange
    serviceCount: 4,
  ),
];

// All Departments Data
final List<DepartmentItem> _allDepartments = [
  // Popular departments
  ..._popularDepartments,
  // Additional departments
  DepartmentItem(
    id: 'public-works',
    name: 'Public Works',
    description: 'Infrastructure, utilities, and maintenance',
    icon: Remix.tools_line,
    color: const Color(0xFF06B6D4), // Cyan
    serviceCount: 7,
  ),
  DepartmentItem(
    id: 'revenue',
    name: 'Revenue',
    description: 'Tax collection, assessments, and payments',
    icon: Remix.money_dollar_circle_line,
    color: const Color(0xFF10B981), // Green
    serviceCount: 5,
  ),
  DepartmentItem(
    id: 'education',
    name: 'Education',
    description: 'Schools, certifications, and educational services',
    icon: Remix.graduation_cap_line,
    color: const Color(0xFFF59E0B), // Amber
    serviceCount: 3,
  ),
  DepartmentItem(
    id: 'agriculture',
    name: 'Agriculture',
    description: 'Farming permits, subsidies, and agricultural support',
    icon: Remix.plant_line,
    color: const Color(0xFF84CC16), // Lime
    serviceCount: 4,
  ),
  DepartmentItem(
    id: 'transport',
    name: 'Transport',
    description: 'Vehicle registration, licenses, and permits',
    icon: Remix.car_line,
    color: const Color(0xFF8B5CF6), // Purple
    serviceCount: 6,
  ),
  DepartmentItem(
    id: 'housing',
    name: 'Housing',
    description: 'Housing applications, subsidies, and permits',
    icon: Remix.home_line,
    color: const Color(0xFFEC4899), // Pink
    serviceCount: 4,
  ),
];
