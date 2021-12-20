import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:inventory/app/api/user_api.dart';
import 'package:inventory/app/helper/local_notification.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data.containsKey('data')) {
    // Handle data message
    // final data = message.data['data'];
  }

  if (message.data.containsKey('notification')) {
    // Handle notification message
    // final notification = message.data['notification'];
  }
  // Or do other work.
}

class FCM {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();

  setNotifications() {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessage.listen(
      (message) async {
        // print('message: $message.data');
        String _title = message.notification!.title!;
        String _body = message.notification!.body!;

        if (message.data.containsKey('data')) {
          // Handle data message
          streamCtlr.sink.add(message.data['data']);
        }
        if (message.data.containsKey('notification')) {
          // Handle notification message
          streamCtlr.sink.add(message.data['notification']);
        }
        if (_title.isNotEmpty && _body.isNotEmpty) {
          await LocalNotification().show(body: _body, title: _title);
        }
        // Or do other work.
        titleCtlr.sink.add(message.notification!.title!);
        bodyCtlr.sink.add(message.notification!.body!);
      },
    );
    // With this token you can test it easily on your phone
    _firebaseMessaging.getToken().then((value) {
      // print('Token: $value');
      UserApi().updateToken(firebaseToken: value);
    });
  }

  dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    titleCtlr.close();
  }
}
