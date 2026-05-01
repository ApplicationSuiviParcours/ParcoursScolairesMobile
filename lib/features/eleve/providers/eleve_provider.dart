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

  Map<String, dynamic>? _noteStats;
  Map<String, dynamic>? get noteStats => _noteStats;

  Future<void> loadNotes({int? childId}) async {
    _isLoading = true;
    _error = null;
    _noteStats = null;
    notifyListeners();

    try {
      final data = await _eleveService.getNotes(childId: childId);
      if (data is List) {
        _notes = data;
        _noteStats = null;
      } else if (data is Map) {
        _notes = data['notes'] ?? data['data'] ?? [];
        _noteStats = data['stats'];
      } else {
        _notes = [];
        _noteStats = null;
      }
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> loadAbsences({int? childId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _eleveService.getAbsences(childId: childId);
      if (data is List) {
        _absences = data;
      } else if (data is Map) {
        _absences = data['absences'] ?? data['data'] ?? [];
      } else {
        _absences = [];
      }
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> loadBulletins({int? childId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _eleveService.getBulletins(childId: childId);
      if (data is List) {
        _bulletins = data;
      } else if (data is Map) {
        _bulletins = data['bulletins'] ?? data['data'] ?? [];
      } else {
        _bulletins = [];
      }
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> loadEmploi({int? childId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final endpoint = childId != null ? 'parent/eleve/$childId/emploi-du-temps' : 'eleve/emploi-du-temps';
      final response = await _eleveService.dioClient.dio.get(endpoint);
      final data = response.data;
      
      List<dynamic> emploiList = [];
      if (data is List) {
        emploiList = data;
      } else if (data is Map) {
        emploiList = data['emploi'] ?? data['data'] ?? [];
      }
      
      _dashboardData = {...?_dashboardData, 'emploi': emploiList};
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<List<dynamic>> loadAgenda() async {
    try {
      return await _eleveService.getAgenda();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  Future<Map<String, dynamic>> getBulletinDetail(int id, {int? childId}) async {
    return await _eleveService.getBulletinDetail(id, childId: childId);
  }
}
