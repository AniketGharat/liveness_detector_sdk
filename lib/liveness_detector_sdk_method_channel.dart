import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'liveness_detector_sdk_platform_interface.dart';

/// An implementation of [LivenessDetectorSdkPlatform] that uses method channels.
class MethodChannelLivenessDetectorSdk extends LivenessDetectorSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('liveness_detector_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
