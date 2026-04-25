import 'package:gestparc/core/constants/api_constants.dart';

class ImageUtils {
  static String getAbsoluteUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    // If it's already a full URL but pointing to localhost, and we are on Android
    // we need to fix it to 10.0.2.2
    if (url.startsWith('http')) {
      // Localhost replacement for emulators
      if (ApiConstants.baseUrl.contains('10.0.2.2')) {
        if (url.contains('localhost')) {
          return url.replaceFirst('localhost', '10.0.2.2');
        } else if (url.contains('127.0.0.1')) {
          return url.replaceFirst('127.0.0.1', '10.0.2.2');
        }
      }
      return url;
    }
    
    // If it's a relative path, append base domain (strip /api/ from baseUrl)
    final rootBase = ApiConstants.baseUrl.replaceAll('/api/', '');
    final cleanUrl = url.startsWith('/') ? url : '/$url';
    
    return '$rootBase$cleanUrl';
  }
}
