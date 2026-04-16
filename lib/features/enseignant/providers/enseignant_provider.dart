import 'package:flutter/material.dart';
import 'package:gestparc/features/enseignant/services/enseignant_service.dart';

class EnseignantProvider extends ChangeNotifier {
  final EnseignantService _enseignantService;
  EnseignantProvider(this._enseignantService);

  bool _isLoading = false;
  Map<String, dynamic>? _stats;
  List<dynamic> _classes = [];
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get stats => _stats;
  List<dynamic> get classes => _classes;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _enseignantService.getDashboardData();
      _stats = response['stats'];
      _classes = response['classes'] ?? [];
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
      final classes = response['classes'] as List? ?? [];
      final classe = classes.firstWhere((c) => c['id'] == classeId, orElse: () => null);
      if (classe != null) {
        // 'matiere' string might need split if it's "Maths, Physiques"
        return (classe['matiere'] as String).split(', ').map((m) => {'nom': m}).toList();
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
}
