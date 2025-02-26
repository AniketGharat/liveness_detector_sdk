
import 'liveness_detector_sdk_platform_interface.dart';

class LivenessDetectorSdk {
  Future<String?> getPlatformVersion() {
    return LivenessDetectorSdkPlatform.instance.getPlatformVersion();
  }
}
