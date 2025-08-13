import 'package:flutter/material.dart';
import '../../core/theme/text_style_helper.dart';
import '../widgets/common_app_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool showUnread = false;

  final List<_NotificationItem> notifications = [
    _NotificationItem(
      title: 'Appointment Reminder',
      message:
          'You have a scheduled appointment with the Grama Niladhari tomorrow at 10:00 A.M. Please arrive on time and bring the required documents.',
      date: DateTime.now(),
      icon: Icons.event,
      iconColor: Color(0xFF2196F3),
      iconBackgroundColor: const Color.fromARGB(
        51,
        33,
        150,
        243,
      ), // 20% opacity
      unread: true,
    ),
    _NotificationItem(
      title: 'Verification Successful',
      message: 'Your Identity has been successfully verified',
      date: DateTime.now().subtract(const Duration(days: 5)),
      icon: Icons.check_circle_rounded,
      iconColor: Color(0xFF4CAF50),
      iconBackgroundColor: const Color.fromARGB(51, 76, 175, 80), // 20% opacity
      unread: false,
    ),
    _NotificationItem(
      title: 'Application under Review',
      message:
          'Your new Identity card application (Ref: #A4521) has been received and is now under review',
      date: DateTime.now().subtract(const Duration(days: 3)),
      icon: Icons.hourglass_bottom_rounded,
      iconColor: Color(0xFFFFC107),
      iconBackgroundColor: const Color.fromARGB(51, 255, 193, 7), // 20% opacity
      unread: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textStyles = TextStyleHelper.instance;
    final filtered = showUnread
        ? notifications.where((n) => n.unread).toList()
        : notifications;
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Notifications',
        showBackButton: true,
        showNotifications: true,
        showProfile: true,
      ),
      backgroundColor: const Color(0xFFF6F8FA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _FilterButton(
                    label: 'All',
                    selected: !showUnread,
                    onTap: () => setState(() => showUnread = false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _FilterButton(
                    label: 'Unread',
                    selected: showUnread,
                    onTap: () => setState(() => showUnread = true),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final n = filtered[i];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: n.iconBackgroundColor,
                      child: Icon(n.icon, color: n.iconColor, size: 28),
                    ),
                    title: Text(n.title, style: textStyles.title16Medium),
                    subtitle: Text(n.message, style: textStyles.body14Regular),
                    trailing: Text(
                      _formatDate(n.date),
                      style: textStyles.body12Regular.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (now.difference(date).inDays == 1) {
      return 'Yesterday';
    } else {
      return '${now.difference(date).inDays} days ago';
    }
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyleHelper.instance.body14Medium.copyWith(
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String message;
  final DateTime date;
  final IconData icon;
  final Color iconColor;
  final bool unread;
  final Color iconBackgroundColor;
  _NotificationItem({
    required this.title,
    required this.message,
    required this.date,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.unread,
  });
}
