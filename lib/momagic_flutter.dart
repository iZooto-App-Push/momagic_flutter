// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:collection';
import 'dart:async';
import 'package:flutter/services.dart';
export 'package:momagic_flutter/src/DATBConnection.dart';
export 'package:momagic_flutter/DATBApns.dart';

typedef ReceiveNotificationParam = void Function(String? payload);
typedef OpenedNotificationParam = void Function(String? data);
typedef TokenNotificationParam = void Function(String? token);
typedef WebViewNotificationParam = void Function(String? landingUrl);

const String FLUTTERSDKNAME = "momagic_flutter";
const String ANDROIDINIT = "DATBAndroidInit";
const String iOSINIT = "iOSInit";
const String iOSAPPID = "appId";
const String SUBSCRIBER_ID = "setSubscriberId";
const String PLUGIN_NAME = "momagic_flutter";
const String RECEIVE_PAYLOAD = "receivedPayload";
const String DEEPLINKNOTIFICATION = "openNotification";
const String HANDLELANDINGURL = "handleLandingURL";
const String ADDUSERPROPERTIES = "addUserProperties";
const String SETSUBSCRIPTION = "DATBSetSubscription";
const String DEVICETOKEN = "onToken";
const String FIREBASEANALYTICS = "DATBFirebaseAnalytics";
const String NOTIFICATIONSOUND = "notificationSound";
const String EVENTS = "DATBAddEvents";
const String PROPERTIES = "DATBAddProperties";
const String ADDTAG = "DATBAddTags";
const String REMOVETAG = "DATBRemoveTags";
const String NOTIFICATIONPREVIEW = "DATBDefaultTemplate";
const String NOTIFICATIONBANNERIMAGE = "DATBDefaultNotificationBanner";
const String KEYEVENTNAME = "eventName";
const String KEYEVENTVALUE = "eventValue";
const String NOTIFICATION_PERMISSION = "notificationPermission";
const String CHANNEL_NAME = "setNotificationChannelName";
const String NAVIGATE_SETTING = "navigateToSettings";
const String DEFAULT_WEB_VIEW = "defaultWebView";


// handle the text-overlay template
enum PushTemplate {
  DEFAULT,
  DEFAULT_NOTIFICATION,
  TEXT_OVERLAY,
  DEVICE_NOTIFICATION_OVERLAY
}

class DATB {
  static DATB shared = DATB();
  static const MethodChannel _channel = MethodChannel(FLUTTERSDKNAME);
  static ReceiveNotificationParam? notificationReceiveData;
  static OpenedNotificationParam? notificationOpenedData;
  static TokenNotificationParam? notificationToken;
  static WebViewNotificationParam? notificationWebView;

  DATB() {
    _channel.setMethodCallHandler(handleOverrideMethod);
  }

  // For integration ios
  static Future<void> iOSInit({required String appId}) async {
    await _channel.invokeMethod(iOSINIT, {iOSAPPID: appId});
  }

  // For Android init (optional defultWebView boolean parameter)
  static Future<void> androidInit({bool isDefaultWebView = false}) async {
    await _channel.invokeMethod(ANDROIDINIT, {DEFAULT_WEB_VIEW: isDefaultWebView});
  }

static addUserProperty(String key, dynamic value) async {
  if (Platform.isIOS) {
    _channel.invokeMethod(ADDUSERPROPERTIES, {
      'key': key,
      'value': value,
    });
  } else {
    Map<String, dynamic> addValue = {};
    addValue[key] = value;
    _channel.invokeMethod(PROPERTIES, addValue);
  }
}


  // For lagecy method used in iOS, this method will be deprecated asap
  static addUserProperties(String key, String value) async {
    _channel.invokeMethod(ADDUSERPROPERTIES, {
      'key': key,
      'value': value,
    });
  }

  static setSubscription(bool enable) async {
    _channel.invokeMethod(SETSUBSCRIPTION, enable);
  }

  static Future<void> setSubscriberId(String subscriberId) async {
    await _channel.invokeMethod(SUBSCRIBER_ID, subscriberId);
  }

  static Future<String?> receiveToken() async {
    final String? receiveToken = await _channel.invokeMethod(DEVICETOKEN);
    return receiveToken;
  }

  static Future<String?> receivePayload() async {
    final String? receivePayload = await _channel.invokeMethod(RECEIVE_PAYLOAD);
    return receivePayload;
  }

  static Future<String?> receiveOpenData() async {
    final String? receiveOpenData =
        await _channel.invokeMethod(DEEPLINKNOTIFICATION);
    return receiveOpenData;
  }

  static Future<String?> receiveLandingURL() async {
    final String? receiveLandingURL =
        await _channel.invokeMethod(HANDLELANDINGURL);
    return receiveLandingURL;
  }

  static Future<void> setFirebaseAnalytics(bool enable) async {
    await _channel.invokeMethod(FIREBASEANALYTICS, enable);
  }

  static Future<void> setNotificationSound(String soundName) async {
    await _channel.invokeMethod(NOTIFICATIONSOUND, soundName);
  }

  static Future<void> addEvent(
      String eventName, Map<String, Object> eventValue) async {
    await _channel.invokeMethod(
        EVENTS, {KEYEVENTNAME: eventName, KEYEVENTVALUE: eventValue});
  }

  static Future<void> addTag(List<String> topicName) async {
    await _channel.invokeMethod(ADDTAG, topicName);
  }

  static Future<void> removeTag(List<String> topicName) async {
    await _channel.invokeMethod(REMOVETAG, topicName);
  }

  /* handled back event*/
  void onNotificationReceived(ReceiveNotificationParam payload) {
    notificationReceiveData = payload;
    _channel.invokeMethod(RECEIVE_PAYLOAD);
  }

  void onNotificationOpened(OpenedNotificationParam data) {
    notificationOpenedData = data;
    _channel.invokeMethod(DEEPLINKNOTIFICATION);
  }

  void onTokenReceived(TokenNotificationParam token) {
    notificationToken = token;
    _channel.invokeMethod(DEVICETOKEN);
  }

  void onWebView(WebViewNotificationParam landingUrl) {
    notificationWebView = landingUrl;
    _channel.invokeMethod(HANDLELANDINGURL);
  }

  static Future<void> setDefaultTemplate(PushTemplate option) async {
    await _channel
        .invokeMethod(NOTIFICATIONPREVIEW, {NOTIFICATIONPREVIEW: option.index});
  }

  static Future<void> promptForPushNotifications() async {
    await _channel.invokeMethod(NOTIFICATION_PERMISSION);
  }

  static Future<void> setDefaultNotificationBanner(String setBanner) async {
    await _channel.invokeMethod(
        NOTIFICATIONBANNERIMAGE, {NOTIFICATIONBANNERIMAGE: setBanner});
  }

  // setNotificationChannelName
  static setNotificationChannelName(String channelName) async {
    _channel.invokeMethod(CHANNEL_NAME, channelName);
  }

  // navigateToNotificationSettings
  static navigateToSettings() async {
    _channel.invokeMethod(NAVIGATE_SETTING);
  }

  Future<Null> handleOverrideMethod(MethodCall methodCall) async {
    if (methodCall.method == RECEIVE_PAYLOAD &&
        notificationReceiveData != null) {
      notificationReceiveData!(methodCall.arguments);
    } else if (methodCall.method == DEEPLINKNOTIFICATION &&
        notificationOpenedData != null) {
      notificationOpenedData!(methodCall.arguments);
    } else if (methodCall.method == DEVICETOKEN && notificationToken != null) {
      notificationToken!(methodCall.arguments);
    } else if (methodCall.method == HANDLELANDINGURL &&
        notificationWebView != null) {
      notificationWebView!(methodCall.arguments);
    }
  }
}
