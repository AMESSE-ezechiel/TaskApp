import 'package:dio/dio.dart';
import 'package:task_app/Models/task_model.dart';

class TaskApiService {
  final Dio _dio;
  final Future<String?> Function()? _getTokenCallback;

  TaskApiService({Future<String?> Function()? getTokenCallback})
    : _getTokenCallback = getTokenCallback,
      _dio = Dio(
        BaseOptions(
          baseUrl: 'https://trasker.dayal-enterprises.com/public/api',
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_getTokenCallback != null) {
            try {
              final token = await _getTokenCallback();
              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (e) {
              print('❌ Erreur token: $e');
            }
          }
          return handler.next(options);
        },
      ),
    );
  }

  // Récupérer toutes les tâches de l'utilisateur
  Future<List<TaskModel>> getUserTasks() async {
    try {
      final response = await _dio.get('/tasks');
      
      if (response.statusCode == 200) {
        final List<dynamic> tasksData = response.data['tasks'];
        return tasksData.map((taskJson) => TaskModel.fromJson(taskJson)).toList();
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Erreur de connexion');
    }
  }

  // Créer une nouvelle tâche
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await _dio.post('/tasks', data: task.toJson());
      
      if (response.statusCode == 201) {
        return TaskModel.fromJson(response.data['task']);
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Erreur de création');
    }
  }

  // Mettre à jour une tâche
  Future<TaskModel> updateTask(String taskId, TaskModel task) async {
    try {
      final response = await _dio.put('/tasks/$taskId', data: task.toJson());
      
      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data['task']);
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Erreur de mise à jour');
    }
  }

  // Mettre à jour le statut d'une tâche
  Future<TaskModel> updateTaskStatus(String taskId, String status) async {
    try {
      final response = await _dio.put('/tasks/$taskId/status', data: {
        'status': status,
      });
      
      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data['task']);
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Erreur de mise à jour du statut');
    }
  }

  // Mettre à jour la priorité d'une tâche
  Future<TaskModel> updateTaskPriority(String taskId, String priority) async {
    try {
      final response = await _dio.put('/tasks/$taskId/priority', data: {
        'priority': priority,
      });
      
      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data['task']);
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Erreur de mise à jour de la priorité');
    }
  }

  // Mettre à jour la date d'échéance
  Future<TaskModel> updateTaskDueDate(String taskId) async {
    try {
      final response = await _dio.put('/tasks/$taskId/due');
      
      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data['task']);
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Erreur de mise à jour de la date');
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    try {
      final response = await _dio.delete('/tasks/$taskId');
      
      if (response.statusCode != 200) {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Erreur de suppression');
    }
  }
}