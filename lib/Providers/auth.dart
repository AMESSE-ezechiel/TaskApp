import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:task_app/Models/users.dart';
import 'package:task_app/Services/auth.api.dart';

class AuthProvider with ChangeNotifier {
  final AuthApiService _apiAuthService = AuthApiService();
  String? _authToken;
  UserModel? _currentUser;
  bool _isLoading = false;

  String? get token => _authToken;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _authToken != null;
  bool get isLoading => _isLoading;

  set token(String? token) {
    _authToken = token;
    notifyListeners();
  }

  String? getAuthToken() => _authToken;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<Response> login(UserModel loginUser) async {
    _setLoading(true);
    try {
      final response = await _apiAuthService.login(loginUser);
      if (response.statusCode == 200) {
        _authToken = response.data['token'];
        if (response.data['user'] != null) {
          _currentUser = UserModel.fromJson(response.data['user']);
        }
        notifyListeners();
      }
      return response;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Response> register(UserModel registeredUser) async {
    _setLoading(true);
    try {
      final response = await _apiAuthService.register(registeredUser);
      if (response.statusCode == 201) {
        _authToken = response.data['token'];
        if (response.data['user'] != null) {
          _currentUser = UserModel.fromJson(response.data['user']);
        }
        notifyListeners();
      }
      return response;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Response> logout() async {
    _setLoading(true);
    try {
      if (_currentUser == null) {
        throw Exception('Aucun utilisateur connecté');
      }
      final response = await _apiAuthService.logout(_currentUser!.id!.toString());
      _authToken = null;
      _currentUser = null;
      notifyListeners();
      return response;
    } catch (e) {
      _authToken = null;
      _currentUser = null;
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Response> getProfile() async {
    _setLoading(true);
    try {
      final response = await _apiAuthService.getProfile();
      if (response.statusCode == 200 && response.data['user'] != null) {
        _currentUser = UserModel.fromJson(response.data['user']);
        notifyListeners();
      }
      return response;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Response> updateProfile(UserModel updatedUser) async {
    _setLoading(true);
    try {
      final response = await _apiAuthService.updateProfile(updatedUser);
      if (response.statusCode == 200 && response.data['user'] != null) {
        _currentUser = UserModel.fromJson(response.data['user']);
        notifyListeners();
      }
      return response;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Charger l'utilisateur depuis le stockage local au démarrage
  Future<void> loadUserFromStorage() async {
    try {
      final response = await getProfile();
      if (response.statusCode == 200) {
        // L'utilisateur est déjà chargé dans getProfile()
      }
    } catch (e) {
      // L'utilisateur n'est pas connecté ou le token est invalide
      _authToken = null;
      _currentUser = null;
    }
  }
}