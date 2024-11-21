import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' hide MessageHandler;
import 'package:momagic_flutter/src/DATBConnection.dart';
typedef WillPresentHandler = Future<bool> Function(Map<String, dynamic>);
class DATBiOS extends PushConnector {
  final MethodChannel _channel = const MethodChannel('izooto_flutter');
  MessageHandler? _onMessage;
  MessageHandler? _onLaunch;
  MessageHandler? _onResume;
  @override
  void configure({
    MessageHandler? onMessage,
    MessageHandler? onLaunch,
    MessageHandler? onResume,
    MessageHandler? onBackgroundMessage,
  }) {
    _onMessage = onMessage;
    _onLaunch = onLaunch;
    _onResume = onResume;
    _channel.setMethodCallHandler(_handleMethod);
    _channel.invokeMethod('configure');
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onToken':
       return token.value = call.arguments;
      case 'receivedPayload':
        return receivePayload.value = call.arguments;
      case 'openNotification':
        return openNotification.value = call.arguments;
      case 'handleLandingURL':
       return openLandingURL.value = call.arguments;
     
      case 'onMessage':
        return _onMessage!(call.arguments.cast<String, dynamic>());
      case 'onLaunch':
        return _onLaunch!(call.arguments.cast<String, dynamic>());
      case 'onResume':
        return _onResume!(call.arguments.cast<String, dynamic>());
      // case 'willPresent':
      //   final payload = call.arguments.cast<String, dynamic>();
      //   return shouldPresent?.call(payload) ?? Future.value(false);

      default:
        throw UnsupportedError('Unrecognized JSON message');
    }
  }

  /// Handler that returns true/false to decide if push alert should be displayed when in foreground.
  /// Returning true will delay onMessage callback until user actually clicks on it
 // late WillPresentHandler shouldPresent;

  // @override
  // final isDisabledByUser = ValueNotifier("");

  @override
  final token = ValueNotifier<String>("");

  @override
  final receivePayload = ValueNotifier<String>("");

  @override
  final openNotification = ValueNotifier<String>("HandleData");

  @override
  final openLandingURL = ValueNotifier<String>("");

  @override
  String get providerType => "APNS";

  @override
  // TODO: implement isDisabledByUser
  ValueNotifier<bool> get isDisabledByUser => throw UnimplementedError();







}
