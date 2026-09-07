import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  static Future<void> showPrayerNotification({
    required String prayerName,
    required String prayerTime,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prayer_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات مواقيت الصلاة',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('athan'),
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'athan.mp3',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      '🕌 حان الآن وقت صلاة $prayerName',
      'صلِّ قبل ما يفوتك - الوقت: $prayerTime',
      details,
    );
  }

  static Future<void> schedulePrayerNotification({
    required String prayerName,
    required String prayerTime,
    required DateTime dateTime,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prayer_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات مواقيت الصلاة',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('athan'),
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'athan.mp3',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      prayerName.hashCode,
      '🕌 حان الآن وقت صلاة $prayerName',
      'صلِّ قبل ما يفوتك - الوقت: $prayerTime',
      tz.TZDateTime.from(dateTime, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prayer_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات مواقيت الصلاة',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('athan'),
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'athan.mp3',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0, // notification id
      '🕌 حان الآن وقت صلاة $prayerName',
      'صلِّ قبل ما يفوتك - الوقت: $prayerTime',
      details,
    );
  }

  static Future<void> schedulePrayerNotification({
    required String prayerName,
    required String prayerTime,
    required DateTime dateTime,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'prayer_channel',
      'مواقيت الصلاة',
      channelDescription: 'إشعارات مواقيت الصلاة',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('athan'),
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'athan.mp3',
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule notification
    await _notifications.zonedSchedule(
      prayerName.hashCode, // unique id
      '🕌 حان الآن وقت صلاة $prayerName',
      'صلِّ قبل ما يفوتك - الوقت: $prayerTime',
      tz.TZDateTime.from(dateTime, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
