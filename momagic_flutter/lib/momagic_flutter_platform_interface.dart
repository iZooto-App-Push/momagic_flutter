import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'momagic_flutter_method_channel.dart';

abstract class MomagicFlutterPlatform extends PlatformInterface {
  /// Constructs a MomagicFlutterPlatform.
  MomagicFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static MomagicFlutterPlatform _instance = MethodChannelMomagicFlutter();

  /// The default instance of [MomagicFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelMomagicFlutter].
  static MomagicFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MomagicFlutterPlatform] when
  /// they register themselves.
  static set instance(MomagicFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
