import 'package:dio/dio.dart';
import 'package:gestparc/core/constants/api_constants.dart';
import 'package:gestparc/core/network/dio_client.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  Future<Map<String, dynamic>> login(String credential, String password, {String role = 'user', bool remember = false}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: {
          'credential': credential,
          if (password.isNotEmpty) 'password': password,
          'role': role,
          'remember': remember,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          return throw Exception(errors.values.first[0]);
        }
        throw Exception(data['message'] ?? 'Erreur lors de la connexion');
      }
      throw Exception('Erreur de connexion au serveur (${e.message})');
    }
  }

  Future<void> logout() async {
    try {
      await _dioClient.dio.post(ApiConstants.logout);
    } catch (e) {
      // Ignorer l'erreur, le token sera de toute façon supprimé du stockage local
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.user);
      return response.data;
    } catch (e) {
      throw Exception('Impossible de récupérer le profil utilisateur');
    }
  }
}
