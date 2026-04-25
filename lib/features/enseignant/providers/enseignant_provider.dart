import 'package:flutter/material.dart';
import 'package:gestparc/features/enseignant/services/enseignant_service.dart';

class EnseignantProvider extends ChangeNotifier {
  final EnseignantService _enseignantService;
  EnseignantProvider(this._enseignantService);

  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  List<dynamic> _assignments = [];
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get stats => _stats;
  List<dynamic> get assignments => _assignments;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _enseignantService.getDashboardData();
      _stats = response['stats'];
      _assignments = response['assignments'] ?? [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> loadClasseEleves(int classeId) async {
    try {
      final response = await _enseignantService.dioClient.dio.get('/enseignant/classes/$classeId/eleves');
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du chargement des élèves');
    }
  }

  Future<Map<String, dynamic>> loadEvaluations({int? classeId}) async {
    try {
      final response = await _enseignantService.dioClient.dio.get(
        '/enseignant/evaluations',
        queryParameters: classeId != null ? {'classe_id': classeId} : null,
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du chargement des évaluations');
    }
  }

  Future<List<dynamic>> loadMatieresForClasse(int classeId) async {
    try {
      // Typically we'd have an endpoint or filter the dashboard data
      // For now, let's assume we can fetch taught classes/matieres
      final response = await _enseignantService.getDashboardData();
      final assignments = response['assignments'] as List? ?? [];
      final assignment = assignments.firstWhere((c) => c['classe_id'] == classeId, orElse: () => null);
      if (assignment != null) {
        return [{'id': assignment['matiere_id'], 'nom': assignment['matiere_nom']}];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotes(int evaluationId, List<Map<String, dynamic>> notes) async {
    try {
      await _enseignantService.dioClient.dio.post('/enseignant/notes', data: {
        'evaluation_id': evaluationId,
        'notes': notes,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement des notes');
    }
  }

  Future<void> saveAbsences(Map<String, dynamic> data) async {
    try {
      await _enseignantService.dioClient.dio.post('/enseignant/absences', data: data);
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement des absences');
    }
  }

  Future<void> createEvaluation(Map<String, dynamic> data) async {
    try {
      await _enseignantService.dioClient.dio.post('/enseignant/evaluations', data: data);
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'évaluation');
    }
  }
}
