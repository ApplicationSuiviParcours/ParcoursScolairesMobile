import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Base URL of the Laravel API
  /// Uses 10.0.2.2 for Android Emulator, localhost for iOS simulator,
  /// and your local IP for physical devices (change this if testing on a real device)
  static String get baseUrl {
    // URL de production hébergée
    return 'https://gestparc.itmaster-africa.com/api/';
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
