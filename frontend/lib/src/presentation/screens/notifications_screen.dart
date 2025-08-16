import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../widgets/common_app_bar.dart';
import 'package:gov_connect/src/core/providers/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool showUnread = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = TextStyleHelper.instance;
    // Create an instance of NotificationProvider if one doesn't exist in the widget tree
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Notifications',
        showBackButton: true,
        showNotifications: true,
        showProfile: true,
      ),
      backgroundColor: const Color(0xFFF6F8FA),
      // Use the specific provider instance to avoid lookup issues
      body: ChangeNotifierProvider.value(
        value: notificationProvider,
        child: Consumer<NotificationProvider>(
          builder: (context, provider, _) {
            if (provider.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(
                child: Text(
                  provider.error!,
                  style: textStyles.body14Regular.copyWith(color: Colors.red),
                ),
              );
            }
            final filtered = showUnread
                ? provider.notifications.where((n) => !n.read).toList()
                : provider.notifications;
            if (filtered.isEmpty) {
              return Center(
                child: Text(
                  'No notifications',
                  style: textStyles.body14Regular,
                ),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                            backgroundColor: n.read
                                ? Theme.of(context).colorScheme.surface
                                : Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.2),
                            child: Icon(
                              Icons.notifications,
                              color: Theme.of(context).primaryColor,
                              size: 28,
                            ),
                          ),
                          title: Text(n.title, style: textStyles.title16Medium),
                          subtitle: Text(
                            n.body,
                            style: textStyles.body14Regular,
                          ),
                          trailing: Text(
                            _formatDate(n.createdAt),
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
            );
          },
        ),
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
