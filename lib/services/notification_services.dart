import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wean_app/models/notificationDataModel.dart';
import 'package:wean_app/screens/chat/product_chat.dart';
import 'package:wean_app/screens/yard/yardInfoScreen.dart';
import 'package:wean_app/services/firebaseServices.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'This channel is used for important notifications.',
  importance: Importance.max,
);

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationServices {
  BuildContext? notificationContext;
  setContext(BuildContext context) => notificationContext = context;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  foregroundNotificaitonStreamSubscription() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
    });
  }

  backgroundNotification() {
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) async {
      if (message != null) await onClickNotificationHandler(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await onClickNotificationHandler(message);
    });
  }

  onClickNotificationHandler(RemoteMessage message) async {
    var messageData = NotificationData.fromMap(message.data);

    if (messageData.type == NotificationType.BID) {
      var item =
          await FirebaseDBServices().loadYardById(messageData.productId!);
      Navigator.push(
        notificationContext!,
        MaterialPageRoute(
          builder: (context) {
            return YardInfoScreen(item: item);
          },
        ),
      );
    }
    if (messageData.type == NotificationType.CHAT) {
      var conversationModel = await FirebaseDBServices()
          .getConversationModelById(messageData.chatId!);
      Navigator.push(
        notificationContext!,
        MaterialPageRoute(
          builder: (context) {
            bool isOwner = FirebaseAuth.instance.currentUser!.uid ==
                conversationModel.ownerId;
            return ProductChat(
              chatReference: conversationModel.documentReference!,
              isOwner: isOwner,
              sentById: isOwner
                  ? conversationModel.senderId
                  : conversationModel.ownerId,
              isProductDeleted: false,
            );
          },
        ),
      );
    }
  }

  showNotification(RemoteMessage message) {
    RemoteNotification notification = message.notification!;
    AndroidNotification android = message.notification!.android!;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }
}
