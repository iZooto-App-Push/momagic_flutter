import 'package:flutter_test/flutter_test.dart';
import 'package:momagic_flutter/momagic_flutter.dart';
import 'package:momagic_flutter/momagic_flutter_platform_interface.dart';
import 'package:momagic_flutter/momagic_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMomagicFlutterPlatform
    with MockPlatformInterfaceMixin
    implements MomagicFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MomagicFlutterPlatform initialPlatform = MomagicFlutterPlatform.instance;

  test('$MethodChannelMomagicFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMomagicFlutter>());
  });

  test('getPlatformVersion', () async {
    MomagicFlutter momagicFlutterPlugin = MomagicFlutter();
    MockMomagicFlutterPlatform fakePlatform = MockMomagicFlutterPlatform();
    MomagicFlutterPlatform.instance = fakePlatform;

    expect(await momagicFlutterPlugin.getPlatformVersion(), '42');
  });
}
