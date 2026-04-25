import 'package:gestparc/core/network/dio_client.dart';

class EleveService {
  final DioClient dioClient;

  EleveService(this.dioClient);

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await dioClient.dio.get('/eleve/dashboard');
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du chargement du tableau de bord élève');
    }
  }

  Future<Map<String, dynamic>> getNotes() async {
    try {
      final response = await dioClient.dio.get('/eleve/notes');
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du chargement des notes');
    }
  }

  Future<Map<String, dynamic>> getAbsences() async {
    try {
      final response = await dioClient.dio.get('/eleve/absences');
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du chargement des absences');
    }
  }

  Future<Map<String, dynamic>> getBulletins() async {
    try {
      final response = await dioClient.dio.get('/eleve/bulletins');
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du chargement des bulletins');
    }
  }

  Future<Map<String, dynamic>> getBulletinDetail(int id) async {
    try {
      final response = await dioClient.dio.get('/eleve/bulletins/$id');
      // La ressource retourne souvent l'objet directement sous 'data' ou à la racine
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Erreur lors du chargement des détails du bulletin');
    }
  }

  Future<List<dynamic>> getAgenda() async {
    try {
      final response = await dioClient.dio.get('/eleve/agenda');
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception('Erreur lors du chargement de l\'agenda');
    }
  }
}
