import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'momagic_flutter_platform_interface.dart';

/// An implementation of [MomagicFlutterPlatform] that uses method channels.
class MethodChannelMomagicFlutter extends MomagicFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('momagic_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
