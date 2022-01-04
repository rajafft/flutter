import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wean_app/services/firebaseServices.dart';

class FirebaseMessagingServices {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final Future<SharedPreferences> _preferences =
      SharedPreferences.getInstance();
  static const String FCM_TOKEN = "FCM_TOKEN";

  checkAndUpdateFCMToken() {
    isFCMChanged().then(
      (Map value) async {
        log(value.toString());
        if ((value['isStored'] && value['isUpdated']) || !value['isStored']) {
          (value['isStored'] && value['isUpdated']) ? log('stored and updated') : log('not stored');
          var fcmToken = await getFCMToken();
          FirebaseDBServices().updateFCMToken(fcmToken!).whenComplete(
            () {
              storeFCMTokenToSharedPreferences(fcmToken);
            },
          );
        }
      },
    );
  }

  Future<String?> getFCMToken() async {
    log('getFCMToken');

    return await _messaging.getToken();
  }

  Future<void> storeFCMTokenToSharedPreferences(String fcmToken) async {
    log('storeFCMTokenToSharedPreferences');
    final SharedPreferences _prefs = await _preferences;
    _prefs.setString(FCM_TOKEN, fcmToken);
  }

  Future<Map> isFCMChanged() async {
    log('isFCMChanged');
    final SharedPreferences _prefs = await _preferences;
    var localFCMToken = _prefs.getString(FCM_TOKEN);

    if (localFCMToken == null) {
      return {
        'isUpdated': false,
        'isStored': false,
      };
    }

    var instanceFCMToken = await getFCMToken();

    return {
      'isUpdated': localFCMToken != instanceFCMToken,
      'isStored': true,
    };
  }
}
