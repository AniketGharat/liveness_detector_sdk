import 'dart:io';
import 'package:flutter/material.dart';
import 'package:liveness_detector_sdk/liveness_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LivenessScreen(),
    );
  }
}

class LivenessScreen extends StatefulWidget {
  @override
  State<LivenessScreen> createState() => _LivenessScreenState();
}

class _LivenessScreenState extends State<LivenessScreen> {
  String? imagePath;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    // Some devices work better when requesting permission at app startup
    _checkInitialPermission();
  }

  // Check permission on startup without prompting
  Future<void> _checkInitialPermission() async {
    var status = await Permission.camera.status;
    print("Initial camera permission status: $status");
  }

  // More robust permission handling
  Future<void> requestCameraPermission() async {
    setState(() => _isInitializing = true);

    try {
      // First check current status with more detailed logging
      PermissionStatus status = await Permission.camera.status;
      print(
          "Current camera permission status on ${Platform.isIOS ? 'iOS' : 'Android'}: $status");

      if (status.isGranted) {
        print("Camera permission already granted");
        startLivenessDetection();
      } else if (status.isDenied) {
        // Request permission with more detailed logging
        print("Requesting camera permission...");
        status = await Permission.camera.request();
        print("Camera permission after request: $status");

        if (status.isGranted) {
          print("Camera permission granted");
          startLivenessDetection();
        } else {
          print("Camera permission denied: $status");
          if (status.isPermanentlyDenied) {
            _showOpenSettingsDialog();
          } else {
            _showPermissionDialog();
          }
        }
      } else {
        print("Unexpected permission status: $status");
        _showPermissionDialog();
      }
    } catch (e) {
      print("Error requesting camera permission: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error requesting camera permission: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission Required'),
        content: Text(
            'This app needs camera access for liveness detection. Please grant camera permission to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await requestCameraPermission();
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission Denied'),
        content: Text(
            'Camera permission is required for this app. Please open settings and enable camera access.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void startLivenessDetection() async {
    try {
      final config = LivenessConfig(
        requiredFrames: 5,
        phaseDuration: Duration(milliseconds: 500),
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LivenessCameraView(
            config: config,
            onResult: (result) {
              print("Liveness detection result: ${result.isSuccess}");
              if (result.isSuccess && result.imagePath != null) {
                setState(() => imagePath = result.imagePath);
              } else if (!result.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Verification failed: ${result.errorMessage ?? "Unknown error"}')),
                );
              }
            },
          ),
        ),
      );
    } catch (e) {
      print("Error starting liveness detection: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting camera: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liveness Detection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  File(imagePath!),
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 20),
            if (_isInitializing)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: requestCameraPermission,
                child: Text('Start Verification'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
