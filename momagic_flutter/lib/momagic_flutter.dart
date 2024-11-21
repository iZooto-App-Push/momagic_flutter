import 'dart:io';
import 'dart:collection';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
export 'package:momagic_flutter/src/DATBConnection.dart';
export 'package:momagic_flutter/DATBApns.dart';

typedef void ReceiveNotificationParam(String? payload);
typedef void OpenedNotificationParam(String? data);
typedef void TokenNotificationParam(String? token);
typedef void WebViewNotificationParam(String? landingUrl);
typedef void OneTapResponse(String? response);

const String PLUGIN_NAME = "momagic_flutter";
const String RECEIVE_PAYLOAD = "receivedPayload"; //receivedPayload
const String ADDUSERPROPERTIES = "addUserProperties";
const String SETSUBSCRIPTION = "DATBSetSubscription";
const String DEVICETOKEN = "onToken";
const String DEEPLINKNOTIFICATION = "openNotification"; //openNotification
const String IZ_NOTIFICATION_DATA = "getNotificationFeed";
const String LANDINGURL = "receiveLandingURL";
const String FIREBASEANALYTICS = "DATBFirebaseAnalytics";
const String ANDROIDINIT = "DATBAndroidInit";
const String NOTIFICATIONSOUND = "notificationSound";
const String EVENTS = "DATBAddEvents";
const String PROPERTIES = "DATBAddProperties";
const String ADDTAG = "DATBAddTags";
const String REMOVETAG = "DATBRemoveTags";
const String HANDLENOTIFICATION = "DATBHandleNotification";
const String HANDLELANDINGURL = "handleLandingURL"; //handleLandingURL
const String NOTIFICATIONPREVIEW = "DATBDefaultTemplate";
const String NOTIFICATIONBANNERIMAGE = "DATBDefaultNotificationBanner";
const String ENABLE = "enable";
const String KEYEVENTNAME = "eventName";
const String KEYEVENTVALUE = "eventValue";
const String iOSINIT = "iOSInit";
const String iOSAPPID = "appId";
const String FLUTTERSDKNAME = "momagic_flutter";
const NOTIFICATION_PERMISSION = "notificationPermission";
const IZ_CHANNEL_NAME = "setNotificationChannelName";
const IZ_NAVIGATE_SETTING = "navigateToSettings";
const IZ_GET_NOTIFICATION_FEED = "getNotificationFeed";
const IZ_IS_PAGINATION = "isPagination";
const IZ_IS_GOOGLE_ONE_TAP = "google_one_tap";

// OneTap support
const String IZ_REQUEST_ONE_TAP_ACTIVITY = "requestOneTapActivity";
const String IZ_SYNC_USER_DETAILS = "syncUserDetails"; // android/ios
const String IZ_EMAIL = "email";
const String IZ_FIRST_NAME = "firstName";
const String IZ_LAST_NAME = "lastName";
const String IZ_ONE_TAP_CALLBACK = "oneTapCallback";

// handle the text-overlay template
enum PushTemplate {
  DEFAULT,
  DEFAULT_NOTIFICATION,
  TEXT_OVERLAY,
  DEVICE_NOTIFICATION_OVERLAY
}

class DATB {
  static DATB shared = new DATB();
  static const MethodChannel _channel = const MethodChannel(FLUTTERSDKNAME);
  static ReceiveNotificationParam? notificationReceiveData;
  static OpenedNotificationParam? notificationOpenedData;
  static TokenNotificationParam? notificationToken;
  static WebViewNotificationParam? notificationWebView;
  static OneTapResponse? dataResponse;

  DATB() {
    _channel.setMethodCallHandler(handleOverrideMethod);
  }

 // for integration ios
  static Future<void> iOSInit({
    required String appId}) async {
    await _channel.invokeMethod(iOSINIT, {
      iOSAPPID: appId
    });
  }
   // This method supports on all plateform(Android/iOS)
  static addUserProperty(String key, String value) async {
    if(Platform.isIOS){
    _channel.invokeMethod(ADDUSERPROPERTIES, {
      'key': key,
      'value': value,
    });
    }else{
      Map<String, Object> addValue = HashMap();
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

    //setSubscription
  }
  static setSubscription(bool enable) async {
    _channel.invokeMethod(SETSUBSCRIPTION, enable);
     
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
 
  // Notification Feed Data
   static Future<String> getNotificationFeed(bool isPagination) async {
     String returnData = await _channel.invokeMethod(IZ_GET_NOTIFICATION_FEED,{IZ_IS_PAGINATION:isPagination});
     return returnData;
   }

  static Future<void> androidInit(bool isDefaultWebView) async {
    await _channel.invokeMethod(ANDROIDINIT, isDefaultWebView);

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

  static Future<void> handleNotification(dynamic data) async {
    await _channel.invokeMethod(HANDLENOTIFICATION, {HANDLENOTIFICATION: data});
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

  static Future<void> setDefaultTemplate(
      PushTemplate option) async {
    await _channel.invokeMethod(NOTIFICATIONPREVIEW,
        {NOTIFICATIONPREVIEW: option.index});

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
    _channel.invokeMethod(IZ_CHANNEL_NAME, channelName);
  }

  // navigateToNotificationSettings
  static navigateToSettings() async {
    _channel.invokeMethod(IZ_NAVIGATE_SETTING);
  }
   
  // OneTap Activity Request
  static Future<void> requestOneTapActivity() async {
    await _channel.invokeMethod(IZ_REQUEST_ONE_TAP_ACTIVITY);
  }

  // OneTap callback Response
  void oneTapResponse(OneTapResponse response) {
     dataResponse = response;
    _channel.invokeMethod(IZ_ONE_TAP_CALLBACK);
  }
  
  // Method to get user details Android/iOSsyncUserDetailsEmail
  static syncUserDetailsEmail(String email, String firstName, String lastName){
    if (Platform.isAndroid){
    Map<String, String> userConfigs = { IZ_EMAIL : email, IZ_FIRST_NAME : firstName, IZ_LAST_NAME : lastName };
    _channel.invokeMethod(IZ_SYNC_USER_DETAILS, userConfigs);
  }
  else{
      _channel.invokeMethod(IZ_SYNC_USER_DETAILS, {
      'email': email,
      'fName': firstName,
      'lName':lastName,
    });  
  }

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
    } else if (methodCall.method == IZ_ONE_TAP_CALLBACK && dataResponse != null){
        dataResponse!(methodCall.arguments);
    }
  }
}