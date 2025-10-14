import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:task_app/Models/users.dart';
import 'package:task_app/Services/auth.api.dart';

class AuthProvider with ChangeNotifier {
  final AuthApiService _apiAuthService = AuthApiService();
  String? _authToken;
  UserModel? _currentUser;

  String? get token => _authToken;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _authToken != null;

  set token(String? token) {
    _authToken = token;
    notifyListeners();
  }

  String? getAuthToken() => _authToken;

  Future<Response> login(UserModel registeredUser) async {
    final response = await _apiAuthService.login(registeredUser);
    if (response.statusCode == 200 || response.statusCode == 201) {
      _authToken = response.data['token'];
      if (response.data['user'] != null) {
        _currentUser = UserModel.fromJson(response.data['user']);
      }
      notifyListeners();
    }
    return response;
  }
  Future<Response> register(UserModel registeredUser) async {
    final response = await _apiAuthService.register(registeredUser);
    if (response.statusCode == 200 || response.statusCode == 201) {
      _authToken = response.data['token'];
      if (response.data['user'] != null) {
        _currentUser = UserModel.fromJson(response.data['user']);
      }
      notifyListeners();
    }
    return response;
  }

  Future<Response> logout(UserModel user) async {
    _authToken = null;
    _currentUser = null;
    notifyListeners();
    return await _apiAuthService.logout(user);
  }

  

  Future<Response> profileUpdate(UserModel updatedUser) async {
    return await _apiAuthService.profileUpdate(updatedUser);
  }

 
}