import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'liveness_detector_sdk_method_channel.dart';

abstract class LivenessDetectorSdkPlatform extends PlatformInterface {
  /// Constructs a LivenessDetectorSdkPlatform.
  LivenessDetectorSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static LivenessDetectorSdkPlatform _instance = MethodChannelLivenessDetectorSdk();

  /// The default instance of [LivenessDetectorSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelLivenessDetectorSdk].
  static LivenessDetectorSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LivenessDetectorSdkPlatform] when
  /// they register themselves.
  static set instance(LivenessDetectorSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
