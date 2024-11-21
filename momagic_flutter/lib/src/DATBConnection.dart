import 'package:flutter/foundation.dart';

typedef Future<void> MessageHandler(Map<String, dynamic> message);

abstract class PushConnector {
  ValueNotifier<bool> get isDisabledByUser;
  ValueNotifier<String> get token;
  ValueNotifier<String> get receivePayload;
  ValueNotifier<String> get openNotification;
  ValueNotifier<String> get openLandingURL;
  String get providerType;
  void configure({
    MessageHandler onMessage,
    MessageHandler onLaunch,
    MessageHandler onResume,
    MessageHandler onBackgroundMessage,
  });
}
