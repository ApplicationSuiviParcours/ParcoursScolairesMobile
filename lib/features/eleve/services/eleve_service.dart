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
}
