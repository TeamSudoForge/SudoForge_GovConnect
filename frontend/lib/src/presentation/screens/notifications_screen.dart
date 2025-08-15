import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_export.dart';
import '../../core/providers/notification_provider.dart';
import '../widgets/common_app_bar.dart';

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
    Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = TextStyleHelper.instance;
    final provider = Provider.of<NotificationProvider>(context);
    final filtered = showUnread
        ? provider.notifications.where((n) => !n.read).toList()
        : provider.notifications;
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Notifications',
        showBackButton: true,
        showNotifications: true,
        showProfile: true,
      ),
      backgroundColor: const Color(0xFFF6F8FA),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                      return GestureDetector(
                        onTap: () async {
                          if (!n.read) {
                            await provider.markAsRead(n.id);
                          }
                        },
                        child: Container(
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
                            border: !n.read
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.25),
                                    width: 1.2,
                                  )
                                : null,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              child: Icon(
                                n.type == 'success'
                                    ? Icons.check_circle_rounded
                                    : Icons.notifications,
                                color: Theme.of(context).primaryColor,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              n.title,
                              style: textStyles.title16Medium.copyWith(
                                fontWeight: !n.read
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              n.message,
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
