// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:todolist/Alarm/alarm_info.dart';
// import 'package:todolist/main.dart';
// import 'package:timezone/timezone.dart' as tz;

// class AlarmSchedule {
//   void scheduleAlarm(
//     DateTime scheduledNotificationDateTime,
//     String title,
//   ) async {
//     var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'alarm_notif',
//       'alarm_notif',
//       channelDescription: 'Channel for Alarm notification',
//       icon: 'codex_logo',
//       sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
//       largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
//     );

//     var platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       title,
//       'Complete your Task',
//       tz.TZDateTime.from(scheduledNotificationDateTime, tz.local),
//       platformChannelSpecifics,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
// }
