import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/notification_repository.dart';
import '../../domain/entities/app_notification.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return SupabaseNotificationRepository(Supabase.instance.client);
});

final notificationListProvider = StateNotifierProvider.autoDispose<
    NotificationController, AsyncValue<List<AppNotification>>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationController(repository)..load();
});

class NotificationController
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationController(this._repository)
      : super(const AsyncValue.loading());

  final NotificationRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.fetchNotifications);
  }

  Future<void> markAsRead(AppNotification notification) async {
    final notifications = state.value;
    if (notifications == null) return;

    state = AsyncValue.data([
      for (final item in notifications)
        if (item.id == notification.id)
          item.copyWith(read: true)
        else
          item,
    ]);

    await _repository.markAsRead(notification.id);
  }
}
