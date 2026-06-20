import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Toggle this flag to switch between local development and production
  static const bool useLocalServer = false;

  /// Production API URL
  static const String productionUrl = 'https://gestparc.itmaster-africa.com/api/';

  /// Local API URLs for different environments
  static const String localAndroidUrl = 'http://10.0.2.2:8000/api/';
  static const String localIosOrDesktopUrl = 'http://localhost:8000/api/';
  static const String localWebUrl = 'http://localhost:8000/api/';
  
  /// If testing on a physical device, replace with your machine's local IP (e.g., http://192.168.1.100:8000/api/)
  static const String localPhysicalDeviceUrl = 'http://192.168.1.100:8000/api/';

  /// Base URL of the Laravel API
  /// Resolves automatically depending on the platform when [useLocalServer] is true.
  static String get baseUrl {
    if (useLocalServer) {
      if (kIsWeb) {
        return localWebUrl;
      }
      // Note: We use localPhysicalDeviceUrl if testing on a real physical device.
      // You can manually return localPhysicalDeviceUrl if testing on physical devices.
      return Platform.isAndroid ? localAndroidUrl : localIosOrDesktopUrl;
    }
    
    // URL de production hébergée
    return productionUrl;
  }

  // Auth endpoints
  static const String login = 'login';
  static const String logout = 'logout';
  static const String user = 'user';

  // Role specific base endpoints
  static const String elevePrefix = 'eleve';
  static const String parentPrefix = 'parent';
  static const String enseignantPrefix = 'enseignant';
}
