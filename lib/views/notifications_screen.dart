// import 'package:flutter/material.dart';
// import 'package:todolist/models/notification_models.dart';

// class NotificationsScreen extends StatelessWidget {
//   final List<NotificationsModel> notifications;

//   NotificationsScreen({required this.notifications});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//       ),
//       body: ListView.builder(
//         itemCount: notifications.length,
//         itemBuilder: (context, index) {
//           NotificationsModel notification = notifications[index];
//           return ListTile(
//             title: Text(notification.title ?? ''),
//             subtitle: Text(notification.time?.toString() ?? ''),
//             // Add more details or customize the UI as needed
//           );
//         },
//       ),
//     );
//   }
// }
