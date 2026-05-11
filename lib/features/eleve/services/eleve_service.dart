import 'package:gestparc/core/network/dio_client.dart';

class EleveService {
  final DioClient dioClient;

  EleveService(this.dioClient);

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await dioClient.dio.get('eleve/dashboard');
      return response.data;
    } catch (e) {
      throw Exception('Erreur tableau de bord: $e');
    }
  }

  Future<dynamic> getNotes({int? childId, int? anneeScolaireId}) async {
    try {
      final endpoint = childId != null ? 'parent/eleve/$childId/notes' : 'eleve/notes';
      final response = await dioClient.dio.get(
        endpoint,
        queryParameters: {
          if (anneeScolaireId != null) 'annee_scolaire_id': anneeScolaireId,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur notes: $e');
    }
  }

  Future<dynamic> getAbsences({int? childId, int? anneeScolaireId}) async {
    try {
      final endpoint = childId != null ? 'parent/eleve/$childId/absences' : 'eleve/absences';
      final response = await dioClient.dio.get(
        endpoint,
        queryParameters: {
          if (anneeScolaireId != null) 'annee_scolaire_id': anneeScolaireId,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur absences: $e');
    }
  }

  Future<dynamic> justifyAbsence(int absenceId, String motif, {int? childId}) async {
    try {
      final endpoint = childId != null 
          ? 'parent/eleve/$childId/absences/$absenceId/justifier'
          : 'eleve/absences/$absenceId/justifier';
      final response = await dioClient.dio.post(
        endpoint,
        data: {'motif': motif},
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors de la justification: $e');
    }
  }

  Future<dynamic> getBulletins({int? childId, int? anneeScolaireId}) async {
    try {
      final endpoint = childId != null ? 'parent/eleve/$childId/bulletins' : 'eleve/bulletins';
      final response = await dioClient.dio.get(
        endpoint,
        queryParameters: {
          if (anneeScolaireId != null) 'annee_scolaire_id': anneeScolaireId,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur bulletins: $e');
    }
  }

  Future<dynamic> getParcours({int? childId}) async {
    try {
      final endpoint = childId != null ? 'parent/eleve/$childId/parcours' : 'eleve/parcours';
      final response = await dioClient.dio.get(endpoint);
      return response.data;
    } catch (e) {
      throw Exception('Erreur parcours: $e');
    }
  }

  Future<dynamic> getBulletinDetail(int id, {int? childId}) async {
    try {
      final endpoint = childId != null ? 'parent/eleve/$childId/bulletins/$id' : 'eleve/bulletins/$id';
      final response = await dioClient.dio.get(endpoint);
      // La ressource retourne souvent l'objet directement sous 'data' ou à la racine
      return response.data['data'] ?? response.data;
    } catch (e) {
      throw Exception('Erreur détail bulletin: $e');
    }
  }

  Future<List<dynamic>> getAgenda() async {
    try {
      final response = await dioClient.dio.get('eleve/agenda');
      return response.data['data'] ?? [];
    } catch (e) {
      throw Exception('Erreur agenda: $e');
    }
  }
}
