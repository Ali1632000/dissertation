import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todolist/main.dart';

class NotificationService {
  scheduleNotifications(
      {String? title, String? description, DateTime? scheduleDate}) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "notifications-youtube",
      "YouTube Notifications",
      priority: Priority.max,
      importance: Importance.max,
    );
// IOS not done
    // DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    //   presentAlert: true,
    //   presentBadge: true,
    //   presentSound: true,
    // );

    NotificationDetails notiDetails = NotificationDetails(
      android: androidDetails,
      // iOS: iosDetails
    );

    // DateTime scheduleDate = DateTime.now().add(Duration(seconds: 5));

    await notificationsPlugin.zonedSchedule(
      0,
      title,
      description,
      tz.TZDateTime.from(scheduleDate!, tz.local),
      notiDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
      payload: "notification-payload",
    );
  }
}
