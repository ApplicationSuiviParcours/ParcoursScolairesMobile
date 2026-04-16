import 'package:flutter/material.dart';
import 'package:gestparc/features/eleve/services/eleve_service.dart';

class EleveProvider extends ChangeNotifier {
  final EleveService _eleveService;

  EleveProvider(this._eleveService);

  bool _isLoading = false;
  Map<String, dynamic>? _dashboardData;
  List<dynamic> _notes = [];
  List<dynamic> _absences = [];
  List<dynamic> _bulletins = [];
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  List<dynamic> get notes => _notes;
  List<dynamic> get absences => _absences;
  List<dynamic> get bulletins => _bulletins;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _eleveService.getDashboardData();
      _dashboardData = data;
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _eleveService.getNotes();
      _notes = data['notes'] ?? [];
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> loadAbsences() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _eleveService.getAbsences();
      _absences = data['absences'] ?? [];
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> loadBulletins() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _eleveService.getBulletins();
      _bulletins = data['bulletins'] ?? [];
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> loadEmploi() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _eleveService.dioClient.dio.get('/eleve/emploi-du-temps');
      _dashboardData = {...?_dashboardData, 'emploi': data.data['emploi']};
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }
}
