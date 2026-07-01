import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/controllers/notification_controller.dart';
import '../../domain/entities/app_notification.dart';

class NotificationCenterButton extends ConsumerWidget {
  const NotificationCenterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider).value ?? [];
    final unreadCount = notifications.where((notification) => !notification.read).length;

    return Stack(
      children: [
        IconButton(
          tooltip: 'Notifikasi',
          icon: const Icon(Icons.notifications_none),
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const NotificationCenterSheet(),
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              height: 16,
              width: 16,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class NotificationCenterSheet extends ConsumerWidget {
  const NotificationCenterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationListProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifikasi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Muat ulang',
                  onPressed: () =>
                      ref.read(notificationListProvider.notifier).load(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            notifications.when(
              data: (items) => items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text('Tidak ada notifikasi terbaru.')),
                    )
                  : Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, index) {
                          final notification = items[index];
                          return _NotificationItem(notification: notification);
                        },
                      ),
                    ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const Text('Gagal memuat notifikasi'),
                    const SizedBox(height: 8),
                    Text(error.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends ConsumerWidget {
  const _NotificationItem({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(notificationListProvider.notifier);
    final date = DateFormat('dd MMM yyyy HH:mm').format(notification.sentAt);

    return ListTile(
      leading: Icon(
        switch (notification.type) {
          NotificationType.reportReady => Icons.picture_as_pdf_outlined,
          NotificationType.attendanceReminder => Icons.fact_check_outlined,
          NotificationType.general => Icons.notifications,
        },
      ),
      title: Text(notification.title,
          style: TextStyle(
            fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
          )),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.message),
          const SizedBox(height: 4),
          Text(date, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      trailing: notification.read
          ? null
          : TextButton(
              onPressed: () => controller.markAsRead(notification),
              child: const Text('Tandai dibaca'),
            ),
    );
  }
}
