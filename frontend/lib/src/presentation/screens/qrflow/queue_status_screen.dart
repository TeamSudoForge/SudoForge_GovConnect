import 'package:flutter/material.dart';
import '../../../core/theme/theme_config.dart';
import '../../../core/utils/text_style_helper.dart';
import '../../widgets/bottom_navigation_widget.dart';

class QueueStatusScreen extends StatelessWidget {
  const QueueStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFFF3F4,
      appBar: AppBar(
        backgroundColor: AppColors.colorFF007B,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Queue Status',
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
            // Your Position Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.colorFF007B.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.access_time,
                      size: 40,
                      color: AppColors.colorFF007B,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Position',
                    style: AppTextStyles.title16Medium.copyWith(
                      color: AppColors.colorFF1717,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '#12',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.colorFF007B,
                    ),
                  ),
                  Text(
                    'in the queue',
                    style: AppTextStyles.body14Regular.copyWith(
                      color: AppColors.colorFF7373,
                    ),
                  ),
                ],
              ),
            ),
            // Queue Information
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Queue Information',
                    style: AppTextStyles.title16Medium.copyWith(
                      color: AppColors.colorFF1717,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Estimated Wait Time', '25-30 mins'),
                  _buildInfoRow('People Ahead', '11'),
                  _buildInfoRow('Average Service Time', '2-3 mins'),
                  _buildInfoRow('Queue Started', '2:15 PM'),
                ],
              ),
            ),
            // Progress Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress',
                    style: AppTextStyles.title16Medium.copyWith(
                      color: AppColors.colorFF1717,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Position Progress',
                        style: AppTextStyles.body14Regular.copyWith(
                          color: AppColors.colorFF5252,
                        ),
                      ),
                      Text(
                        '12 of 23',
                        style: AppTextStyles.body14Medium.copyWith(
                          color: AppColors.colorFF1717,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 12 / 23,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.colorFF007B,
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.colorFF007B,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You\'ve moved up 3 positions in the last 10 minutes',
                          style: AppTextStyles.body12Regular.copyWith(
                            color: AppColors.colorFF7373,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Recent Activity
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: AppTextStyles.title16Medium.copyWith(
                      color: AppColors.colorFF1717,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActivityItem(
                    icon: Icons.arrow_upward,
                    iconColor: Colors.green,
                    title: 'Moved to position #12',
                    time: '2:45 PM',
                  ),
                  const SizedBox(height: 12),
                  _buildActivityItem(
                    icon: Icons.person_add,
                    iconColor: AppColors.colorFF7373,
                    title: 'Joined queue at position #15',
                    time: '2:15 PM',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Refresh Status Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Refresh queue status
                },
                icon: Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Refresh Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorFF007B,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // Set Notification Alert Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Set notification alert
                },
                icon: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.colorFF1717,
                ),
                label: Text(
                  'Set Notification Alert',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.colorFF1717,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.colorFFD4D4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // Leave Queue Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // TODO: Show leave queue confirmation
                },
                child: Text(
                  'Leave Queue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(
        currentItem: BottomNavItem.services,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body14Regular.copyWith(
              color: AppColors.colorFF5252,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body14Medium.copyWith(
              color: AppColors.colorFF1717,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body14Regular.copyWith(
                  color: AppColors.colorFF1717,
                ),
              ),
              Text(
                time,
                style: AppTextStyles.body12Regular.copyWith(
                  color: AppColors.colorFF7373,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
