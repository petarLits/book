import 'dart:convert';

import 'package:book/core/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseMessageManager {
  static FirebaseMessageManager? _instance;
  late FirebaseMessaging firebaseMessaging;
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late bool isFlutterLocalNotificationsInitialized;
  late BehaviorSubject<String?> onNotificationClick;

  FirebaseMessageManager._internal() {
    firebaseMessaging = FirebaseMessaging.instance;
    channel = AndroidNotificationChannel(
      'channelId',
      'channelName',
      importance: Importance.max,
    );
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    isFlutterLocalNotificationsInitialized = false;
    onNotificationClick = BehaviorSubject();
  }

  factory FirebaseMessageManager() {
    if (_instance == null) {
      _instance = FirebaseMessageManager._internal();
    }
    return _instance!;
  }

  static FirebaseMessageManager get instance => FirebaseMessageManager();

  Future<bool> sendPushMessage({
    String? recipientToken,
    String? topic,
    String? imageUrl,
    required String title,
    required String body,
    Map<String, dynamic>? additionalData,
  }) async {
    final jsonCredentials = await rootBundle
        .loadString('assets/book-bloc-c83676f5d8dd.json')
        .timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });
    final creds = ServiceAccountCredentials.fromJson(jsonCredentials);

    final client = await clientViaServiceAccount(
      creds,
      ['https://www.googleapis.com/auth/cloud-platform'],
    ).timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });

    final notificationData = {
      'message': {
        'token': recipientToken,
        'topic': topic,
        'data': additionalData,
        'notification': {'title': title, 'body': body, 'image': imageUrl ?? ''},
      },
    };

    const String senderId = '592607300007';
    final response = await client
        .post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$senderId/messages:send'),
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode(notificationData),
    )
        .timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });

    client.close();
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  Future<void> initializeLocalNotification() async {
    await flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
            android: AndroidInitializationSettings('@drawable/background')),
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse);
  }

  void _onDidReceiveNotificationResponse(NotificationResponse details) {
    if (details.payload != null && details.payload!.isNotEmpty) {
      onNotificationClick.add(details.payload);
    }
  }
  Future<void> showLocalNotification(RemoteMessage message) async {
    final notificationDetails = await _notificationDetails();
    flutterLocalNotificationsPlugin.show(
        DateTime.now().microsecond,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: jsonEncode(message.data));
  }
  Future<NotificationDetails> _notificationDetails() async {
    final AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('channelID', 'channelName',
        channelDescription: 'description',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true);

    final DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails();

    return NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
  }
}
