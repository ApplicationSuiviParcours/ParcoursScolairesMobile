import 'package:flutter/material.dart';
import 'package:gestparc/features/parent/services/parent_service.dart';

class ParentProvider extends ChangeNotifier {
  final ParentService _parentService;
  ParentProvider(this._parentService);

  bool _isLoading = false;
  List<dynamic> _enfants = [];
  Map<String, dynamic>? _selectedEnfant;
  Map<String, dynamic>? _statsGlobal;
  String? _error;

  bool get isLoading => _isLoading;
  List<dynamic> get enfants => _enfants;
  Map<String, dynamic>? get selectedEnfant => _selectedEnfant;
  Map<String, dynamic>? get statsGlobal => _statsGlobal;
  String? get error => _error;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _parentService.getDashboardData();
      _enfants = response['data'] ?? [];
      _statsGlobal = response['stats_global'];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectEnfant(Map<String, dynamic> enfant) {
    _selectedEnfant = enfant;
    notifyListeners();
  }
}
