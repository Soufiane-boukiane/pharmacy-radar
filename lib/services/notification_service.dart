import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    // Default to GMT+1 (Africa/Casablanca)
    tz.setLocalLocation(tz.getLocation('Africa/Casablanca'));

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String soundName, // 'med_alert.mp3' or 'doc_alert.mp3'
  }) async {
    // Ensure GMT+1 logic
    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      soundName == 'med_alert' ? 'medication_channel' : 'appointment_channel',
      soundName == 'med_alert' ? 'Medication Reminders' : 'Doctor Appointments',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(soundName),
      playSound: true,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentSound: true,
      sound: '$soundName.aiff', // iOS requires .aiff or .caf usually
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
