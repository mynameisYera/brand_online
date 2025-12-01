import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:brand_online/roadMap/service/task_service.dart';

class FirebaseUtil {
  static final FirebaseUtil _instance = FirebaseUtil._internal();
  factory FirebaseUtil() => _instance;

  FirebaseUtil._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<String?> initialize() async {
  await _initializeLocalNotifications();

  final NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    log('[FirebaseUtil] have permission: ${settings.authorizationStatus}');

    if (Platform.isIOS) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true, 
        badge: true, 
        sound: true, 
      );
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('[FirebaseUtil] Received foreground message: ${message.messageId}');
      final bool isDataOnly = message.notification == null;
      if (isDataOnly) {
        _showLocalNotification(message);
      }
    });

    final String? fcmToken = await _firebaseMessaging.getToken();
    TaskService().sendFcmToken(fcmToken: fcmToken);
    print('[FirebaseUtil] FCM token: $fcmToken');

    if (Platform.isIOS || Platform.isMacOS) {
      final String? apnsToken = await _firebaseMessaging.getAPNSToken();
      print('[FirebaseUtil] APNS token: $apnsToken');
    }

    return fcmToken;
  } else {
    log('[FirebaseUtil] no permission: ${settings.authorizationStatus}');
    return null;
  }
}

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log('[FirebaseUtil] Notification tapped: ${response.payload}');
      },
    );

    // Запрос разрешений для Android 13+
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      // Создание канала уведомлений для Android
      await _createNotificationChannel();
    }
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
  final String title =
      message.notification?.title ??
      message.data['title'] ??
      'Уведомление';

  final String body =
      message.notification?.body ??
      message.data['body'] ??
      '';

  await _localNotifications.show(
    message.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: message.notification?.android?.smallIcon ??
            '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      ),
    ),
    payload: message.data.toString(),
  );

  log('[FirebaseUtil] Local notification shown: $title - $body');
}

  Future<String?> getFCMToken() async {
    final token = await _firebaseMessaging.getToken();
    print('[FirebaseUtil] getFCMToken: $token');
    return token;
  }

  Future<String?> getApnsToken() async {
    final token = await _firebaseMessaging.getAPNSToken();
    print('[FirebaseUtil] getApnsToken: $token');
    return token;
  }

  Future<NotificationSettings> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print(settings.authorizationStatus);
    return settings;
  }
}
