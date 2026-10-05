import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/subscriptions/presentation/bloc/subscription_bloc.dart';
import 'package:get_it/get_it.dart';

class NotificationProcess {
  static String myFcmToken = '';
  static Future<String?> fcmToken() async {
    try {
      myFcmToken = await FirebaseMessaging.instance.getToken() ?? '';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('error while get fcm token: $e');
      }
    }
    log(myFcmToken.toString());
    return myFcmToken;
  }

  void onRefreshToken() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint('onRefreshToken: $token');
    });
  }

  static Future<void> _setForegroundNotificationPresentationOptions() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> requestPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Firebase Messaging Permissions denied $e");
      }
    }
  }

  static Future<void> setupInteractedMessage() async {
    FirebaseMessaging.onMessage.listen(
      (message) => _handleMessage(message, true),
    ); // foreground
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleMessage(message, false),
    ); // background
    final initialMessage = await FirebaseMessaging.instance
        .getInitialMessage(); // terminated
    if (initialMessage != null) {
      _handleMessage(initialMessage, false);
    }
  }

  static void _handleMessage(RemoteMessage message, bool fromForeground) {
    if (kDebugMode) {
      debugPrint("message: ${message.toMap()}");
      debugPrint("message data: ${message.data}");
      debugPrint("message title: ${message.notification?.title}");
      debugPrint("message body: ${message.notification?.body}");
    }
    if (message.data['type'] == 'SUBSCRIPTION_REQUEST_REVIEWED') {
      GetIt.I<SubscriptionBloc>().add(LoadCourseInterests());
      GetIt.I<HomeBloc>()
        ..add(GetMyActiveCourses())
        ..add(GetMyInActiveCourses());
      final isRejected = message.data['status'] == 'REJECTED';
      final adminNote = message.data['adminNote']?.toString().trim();
      if (fromForeground && isRejected) {
        showMessage(
          adminNote == null || adminNote.isEmpty
              ? 'تم رفض طلب الاشتراك. يمكنك مراجعة تفاصيل الدفع والمحاولة مجددًا.'
              : 'تم رفض طلب الاشتراك: $adminNote',
        );
      }
    }
  }

  static Future<void> init() async {
    Future.wait([
      requestPermission(),
      _setForegroundNotificationPresentationOptions(),
      fcmToken(),
      setupInteractedMessage(),
    ]);

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> enableTopic(String topic) async {
    try {
      FirebaseMessaging.instance.subscribeToTopic(topic);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error While Enable Topic $e');
      }
    }
  }

  Future<void> disableTopic(String topic) async {
    try {
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error While Disable Topic $e');
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
