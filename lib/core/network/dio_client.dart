import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestparc/core/constants/api_constants.dart';

class DioClient {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Injection du token d'authentification
          final token = await _secureStorage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Gestion basique des erreurs (ex: token expiré)
          if (e.response?.statusCode == 401) {
            await _secureStorage.delete(key: 'auth_token');
            await _secureStorage.delete(key: 'user_role');
            // Gérer la déconnexion globale ici ou notifier le state
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
