
import 'momagic_flutter_platform_interface.dart';

class MomagicFlutter {
  Future<String?> getPlatformVersion() {
    return MomagicFlutterPlatform.instance.getPlatformVersion();
  }
}
