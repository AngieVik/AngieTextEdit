import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling OS permissions
class PermissionService {
  PermissionService._();

  /// Check if storage permission is granted
  static Future<bool> hasStoragePermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      return status.isGranted;
    }
    // iOS and desktop don't need explicit storage permission
    return true;
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Check Android version - Android 13+ uses different permissions
      if (await Permission.photos.status.isDenied) {
        // Try requesting photos permission for Android 13+
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) return true;
      }

      // Try regular storage permission
      final status = await Permission.storage.request();
      if (status.isGranted) return true;

      // For Android 11+, try manage external storage
      if (await Permission.manageExternalStorage.status.isDenied) {
        final manageStatus = await Permission.manageExternalStorage.request();
        return manageStatus.isGranted;
      }

      return false;
    }
    return true;
  }

  /// Check if microphone permission is granted (for TTS on some platforms)
  static Future<bool> hasMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Request microphone permission
  static Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Check if speech permission is granted
  static Future<bool> hasSpeechPermission() async {
    final status = await Permission.speech.status;
    return status.isGranted;
  }

  /// Request speech permission
  static Future<bool> requestSpeechPermission() async {
    final status = await Permission.speech.request();
    return status.isGranted;
  }

  /// Check all required permissions for the app
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'storage': await hasStoragePermission(),
      'microphone': await hasMicrophonePermission(),
      'speech': await hasSpeechPermission(),
    };
  }

  /// Request all required permissions
  static Future<Map<String, bool>> requestAllPermissions() async {
    final results = <String, bool>{};

    results['storage'] = await requestStoragePermission();
    results['microphone'] = await requestMicrophonePermission();
    results['speech'] = await requestSpeechPermission();

    return results;
  }

  /// Open app settings for manual permission grant
  static Future<bool> openAppSettings() async {
    return await openAppSettings();
  }

  /// Check if permission is permanently denied
  static Future<bool> isStoragePermanentlyDenied() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      return status.isPermanentlyDenied;
    }
    return false;
  }
}
