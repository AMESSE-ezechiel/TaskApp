import 'package:dio/dio.dart';
import 'package:task_app/Models/tasks.dart';

class TaskApiService {
  final Dio _dio;
  final Future<String?> Function()? _getTokenCallback;

  TaskApiService({Future<String?> Function()? getTokenCallback})
      : _getTokenCallback = getTokenCallback,
        _dio = Dio(
          BaseOptions(
            baseUrl: 'http://127.0.0.1:8000/api',
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
                print('🔑 Token ajouté aux statistiques');
              }
            } catch (e) {
              print('❌ Erreur token statistiques: $e');
            }
          }
          return handler.next(options);
        },
      ),
    );
  }

  Future<TaskModel> getUserTasks(UserModel userData) async {
    try {
      print('🔄 Requête API tasks pour user ID: ${userData.name}');

      final response = await _dio.get(
        '/tasks',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      print('✅ Réponse API stats: ${response.statusCode}');

      switch (response.statusCode) {
        case 200:
          final responseData = response.data;
          print('📊 Données stats reçues: $responseData');
          
          // Gérer différents formats de réponse
          if (responseData['tasks'] != null) {
            return TaskModel.fromJson(responseData['tasks']);
          } else if (responseData['data'] != null) {
            return TaskModel.fromJson(responseData['data']);
          } else {
            return TaskModel.fromJson(responseData);
          }
        
        case 404:
          print('📊 Aucune tâche trouvée, utilisation des données par défaut');
          return _getDefaultTask(userData);
        
        case 401:
          throw Exception('Non authentifié. Veuillez vous reconnecter.');
        
        default:
          throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erreur Dio stats: ${e.message}');
      print('📡 Response stats: ${e.response?.data}');
      
      // En cas d'erreur de connexion, retourner des données par défaut
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        print('🌐 Timeout connexion, retour données par défaut');
        return _getDefaultTask(userData);
      }
      
      throw Exception(e.response?.data?['message'] ?? 'Erreur de connexion');
    } catch (e) {
      print('❌ Erreur inattendue stats: $e');
      // Retourner des données par défaut en cas d'erreur inattendue
      return _getDefaultTask(userData);
    }
  }

  TaskModel _getDefaultTask(UserModel userData) {
    return TaskModel(
      id: 0,
      title: 'Aucune tâche',
      description: 'Aucune description',
      status: 'inconnu',
      priority: 'basse',
      dueDate: DateTime.now().toString(),
      userId: userData.id ?? 0,
    );
  }
  

 
}