import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import '../../../core/theme/theme_config.dart';
import '../../../core/utils/text_style_helper.dart';
import 'queue_status_screen.dart';
import 'indoor_map_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;

  const ServiceDetailScreen({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteCustom,
      appBar: AppBar(
        backgroundColor: AppColors.colorFF007B,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '$title Service',
          style: AppTextStyles.title20.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.colorFF007B, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Service image
            Container(
              height: 200,
              width: double.infinity,
              child: Image.asset(
                'assets/qrflow_images/idservice.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Token section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Your Token Number',
                    style: AppTextStyles.body14Regular.copyWith(
                      color: AppColors.colorFF7373,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A-247',
                    style: TextStyle(
                      fontSize: 48,
                      color: AppColors.colorFF1717,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generated on Jan 15, 2025 at 2:30 PM',
                    style: AppTextStyles.body12Regular.copyWith(
                      color: AppColors.colorFF7373,
                    ),
                  ),
                ],
              ),
            ),
            // View Map button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => IndoorMapScreen(
                        destination: 'Counter 1',
                        service: '$title Service',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorFF007B,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View Map',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Required Documents section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Required Documents',
                    style: AppTextStyles.title16Medium.copyWith(
                      color: AppColors.colorFF1717,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentItem('Birth Certificate', true),
                  _buildDocumentItem('Proof of Address', true),
                  _buildDocumentItem('Passport Photo (2×2)', true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Estimated Processing Time
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.colorFFF3F4.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppColors.colorFF007B,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Estimated Processing Time',
                    style: AppTextStyles.body14Regular.copyWith(
                      color: AppColors.colorFF5252,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '15-20 minutes',
                    style: AppTextStyles.body14Medium.copyWith(
                      color: AppColors.colorFF007B,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // View Queue Status button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const QueueStatusScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorFF1717,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View Queue Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.colorFF007B,
        unselectedItemColor: AppColors.colorFF7373,
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterRemix.apps_2_line),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          // TODO: Handle navigation
        },
      ),
    );
  }

  Widget _buildDocumentItem(String document, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isChecked ? AppColors.colorFF007B : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isChecked ? AppColors.colorFF007B : AppColors.colorFFD4D4,
                width: 2,
              ),
            ),
            child: isChecked
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            document,
            style: AppTextStyles.body14Regular.copyWith(
              color: AppColors.colorFF5252,
            ),
          ),
        ],
      ),
    );
  }
}