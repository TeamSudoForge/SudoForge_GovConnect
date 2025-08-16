import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../core/app_export.dart';
import '../../core/theme/theme_config.dart';
import '../widgets/bottom_navigation_widget.dart';

class AllServicesScreen extends StatefulWidget {
  static const String routeName = '/all-services';

  const AllServicesScreen({Key? key}) : super(key: key);

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

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
          'All Services',
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
                  'Services',
                  style: styles.headline24.copyWith(
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hi You can access various services offered by the\ngovernment from here',
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
                      hintText: 'Search for a service',
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
                _buildTab('Recent', isSelected: false, onTap: () {
                  context.pop(); // Go back to recent services
                }),
                const SizedBox(width: 12),
                _buildTab('All', isSelected: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Services Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _allServices.length,
                itemBuilder: (context, index) {
                  final service = _allServices[index];
                  return _buildServiceCard(service, theme, styles);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationWidget(
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

  Widget _buildServiceCard(ServiceItem service, ThemeData theme, TextStyleHelper styles) {
    return GestureDetector(
      onTap: () {
        // Navigate to specific service
        print('Tapped on ${service.title}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: service.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service.icon,
                size: 24,
                color: service.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service.title,
              style: styles.body12Regular.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceItem {
  final String title;
  final IconData icon;
  final Color color;

  const ServiceItem({
    required this.title,
    required this.icon,
    required this.color,
  });
}

// All Services Data (including recent ones + additional ones)
final List<ServiceItem> _allServices = [
  // Recent Services
  ServiceItem(
    title: 'ID Services',
    icon: Remix.id_card_line,
    color: const Color(0xFF3B82F6), // Blue
  ),
  ServiceItem(
    title: 'Housing',
    icon: Remix.home_line,
    color: const Color(0xFF8B5CF6), // Purple
  ),
  ServiceItem(
    title: 'Vehicle',
    icon: Remix.car_line,
    color: const Color(0xFF8B5CF6), // Purple
  ),
  ServiceItem(
    title: 'Education',
    icon: Remix.graduation_cap_line,
    color: const Color(0xFFF97316), // Orange
  ),
  ServiceItem(
    title: 'HealthCare',
    icon: Remix.health_book_line,
    color: const Color(0xFFEF4444), // Red
  ),
  ServiceItem(
    title: 'Trade',
    icon: Remix.exchange_line,
    color: const Color(0xFF8B5CF6), // Purple
  ),
  ServiceItem(
    title: 'Licensing',
    icon: Remix.file_text_line,
    color: const Color(0xFFEF4444), // Red
  ),
  ServiceItem(
    title: 'Elections',
    icon: Remix.government_line,
    color: const Color(0xFFEC4899), // Pink
  ),
  ServiceItem(
    title: 'Agriculture',
    icon: Remix.plant_line,
    color: const Color(0xFF10B981), // Green
  ),
  // Additional Services
  ServiceItem(
    title: 'Pensions',
    icon: Remix.user_line,
    color: const Color(0xFFF97316), // Orange
  ),
  ServiceItem(
    title: 'Sanitation',
    icon: Remix.recycle_line,
    color: const Color(0xFF06B6D4), // Cyan
  ),
  ServiceItem(
    title: 'Tourism',
    icon: Remix.map_line,
    color: const Color(0xFF8B5CF6), // Purple
  ),
  ServiceItem(
    title: 'Electricity',
    icon: Remix.flashlight_line,
    color: const Color(0xFFF59E0B), // Amber
  ),
  ServiceItem(
    title: 'Loans',
    icon: Remix.bank_line,
    color: const Color(0xFF8B5CF6), // Purple
  ),
  ServiceItem(
    title: 'Immigration',
    icon: Remix.passport_line,
    color: const Color(0xFFF59E0B), // Amber
  ),
];
