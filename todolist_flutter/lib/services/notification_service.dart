// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest_all.dart' as tz;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> init() async {
//     tz.initializeTimeZones(); // Inisialisasi timezone

//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings settings = InitializationSettings(
//       android: androidSettings,
//     );

//     await _notificationsPlugin.initialize(settings);
//   }

//   static Future<void> scheduleNotification(
//     int id,
//     String title,
//     String body,
//     DateTime deadline,
//   ) async {
//     // Hitung waktu H-1 deadline
//     DateTime scheduledTime = deadline.subtract(Duration(days: 1));

//     // Konversi ke waktu lokal untuk zonedSchedule
//     final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(
//       scheduledTime,
//       tz.local,
//     );

//     await _notificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.from(scheduledTime, tz.local),
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'todo_channel',
//           'Todo Reminders',
//           channelDescription: 'Pengingat untuk tugas yang akan datang',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//       androidScheduleMode:
//           AndroidScheduleMode.exactAllowWhileIdle, // Tambahkan ini
//     );
//   }
// }
