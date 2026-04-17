import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gestparc/features/auth/services/auth_service.dart';

enum AuthState { initial, unauthenticated, authenticating, authenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  AuthState _status = AuthState.initial;
  Map<String, dynamic>? _user;
  String? _role;
  String? _savedMatricule;

  AuthProvider(this._authService) {
    _checkAuthStatus();
  }

  AuthState get status => _status;
  Map<String, dynamic>? get user => _user;
  String? get role => _role;
  String? get savedMatricule => _savedMatricule;

  Future<void> _checkAuthStatus() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final savedRole = await _secureStorage.read(key: 'user_role');
    _savedMatricule = await _secureStorage.read(key: 'saved_matricule');
    
    if (token != null && savedRole != null) {
      _role = savedRole;
      _status = AuthState.authenticated;
      
      // Optionally fetch latest user profile
      try {
        final userData = await _authService.getUserProfile();
        _user = userData['user'];
      } catch (e) {
        // Keeping the status as authenticated if network fails but token exists
      }
    } else {
      _status = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String credential, String password, {String role = 'user', bool remember = false}) async {
    _status = AuthState.authenticating;
    notifyListeners();

    try {
      final data = await _authService.login(credential, password, role: role, remember: remember);
      
      final token = data['token'];
      _user = data['user'];
      
      // Extract role from UserResource returned by the API
      if (_user != null && _user!.containsKey('role')) {
        _role = _user!['role'];
      } else {
        _role = 'eleve'; // Default fallback
      }

      await _secureStorage.write(key: 'auth_token', value: token);
      await _secureStorage.write(key: 'user_role', value: _role);

      if (remember) {
        await _secureStorage.write(key: 'saved_matricule', value: credential);
        _savedMatricule = credential;
      } else {
        await _secureStorage.delete(key: 'saved_matricule');
        _savedMatricule = null;
      }

      _status = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthState.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    _status = AuthState.authenticating;
    notifyListeners();
    
    try {
      await _authService.logout();
    } finally {
      await _secureStorage.delete(key: 'auth_token');
      await _secureStorage.delete(key: 'user_role');
      _user = null;
      _role = null;
      _status = AuthState.unauthenticated;
      notifyListeners();
    }
  }
}
