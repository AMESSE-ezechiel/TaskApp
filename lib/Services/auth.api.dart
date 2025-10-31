import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_app/Models/users.dart';

class AuthApiService extends ChangeNotifier {
  final Dio _dio;

  AuthApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://trasker.dayal-enterprises.com/public/api',
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getStoredToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<Response> login(UserModel loginUser) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': loginUser.email,
        'password': loginUser.password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          await _saveToken(token);
        }
      }
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  Future<Response> register(UserModel registeredUser) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'email': registeredUser.email,
          'name': registeredUser.name,
          'password': registeredUser.password,
        },
      );

      if (response.statusCode == 201) {
        final token = response.data['token'];
        if (token != null) {
          await _saveToken(token);
        }
      }
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  Future<Response> logout(String userId) async {
    try {
      final response = await _dio.post('/logout/$userId');
      await _clearToken();
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }

  Future<Response> getProfile() async {
    try {
      final response = await _dio.get('/profile');
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _clearToken();
      }
      rethrow;
    }
  }

  Future<Response> updateProfile(UserModel updatedUser) async {
    try {
      final response = await _dio.put('/update', data: {
        'name': updatedUser.name,
        'email': updatedUser.email,
        if (updatedUser.password != null && updatedUser.password!.isNotEmpty)
          'password': updatedUser.password,
      });
      return response;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message);
    }
  }
}