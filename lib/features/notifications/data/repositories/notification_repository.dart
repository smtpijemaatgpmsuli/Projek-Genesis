import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> fetchNotifications();
  Future<void> markAsRead(String notificationId);
}

class SupabaseNotificationRepository implements NotificationRepository {
  SupabaseNotificationRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final data = await _client
        .from('notifications')
        .select()
        .order('sent_at', ascending: false)
        .limit(20);

    return (data as List<dynamic>)
        .map((raw) => AppNotification.fromMap(raw as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'read': true})
        .eq('id', notificationId);
  }
}
