import 'package:flutter_test/flutter_test.dart';
import 'package:liveness_detector_sdk/liveness_detector_sdk.dart';
import 'package:liveness_detector_sdk/liveness_detector_sdk_platform_interface.dart';
import 'package:liveness_detector_sdk/liveness_detector_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLivenessDetectorSdkPlatform
    with MockPlatformInterfaceMixin
    implements LivenessDetectorSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LivenessDetectorSdkPlatform initialPlatform = LivenessDetectorSdkPlatform.instance;

  test('$MethodChannelLivenessDetectorSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLivenessDetectorSdk>());
  });

  test('getPlatformVersion', () async {
    LivenessDetectorSdk livenessDetectorSdkPlugin = LivenessDetectorSdk();
    MockLivenessDetectorSdkPlatform fakePlatform = MockLivenessDetectorSdkPlatform();
    LivenessDetectorSdkPlatform.instance = fakePlatform;

    expect(await livenessDetectorSdkPlugin.getPlatformVersion(), '42');
  });
}
