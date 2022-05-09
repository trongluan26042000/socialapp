import 'package:app1/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi {
  static Future notificationDetails() async {
    return NotificationDetails(
        android: AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
    ));
  }

  static final _notifications = FlutterLocalNotificationsPlugin();
  static Future showNotification(String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Channel id', 'Your notification ID',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title + ' 🔔',
      body + ' gg!',
      platformChannelSpecifics,
      payload:
          'Message - There is a new notification on your account, kindly check it out',
    );
  }
}
