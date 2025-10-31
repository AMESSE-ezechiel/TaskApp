import 'package:flutter/foundation.dart';
import 'package:task_app/Models/task_model.dart';
import 'package:task_app/Providers/auth.dart';
import 'package:task_app/Services/task.api.dart';

class TaskProvider with ChangeNotifier {
  final TaskApiService _taskApiService;
  final AuthProvider _authProvider;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String _errorMessage = '';

  TaskProvider(this._authProvider)
    : _taskApiService = TaskApiService(
        getTokenCallback: () => Future.value(_authProvider.token),
      );

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  // Tâches filtrées par statut
  List<TaskModel> get pendingTasks => _tasks.where((task) => task.status?.value == 'en_attente').toList();
  List<TaskModel> get inProgressTasks => _tasks.where((task) => task.status?.value == 'en_cours').toList();
  List<TaskModel> get completedTasks => _tasks.where((task) => task.status?.value == 'termine').toList();
  List<TaskModel> get cancelledTasks => _tasks.where((task) => task.status?.value == 'annule').toList();

  // Charger toutes les tâches de l'utilisateur
  Future<void> loadUserTasks() async {
    _setLoading(true);
    _errorMessage = '';

    try {
      if (_authProvider.currentUser == null) {
        throw Exception('Utilisateur non authentifié');
      }
      
      _tasks = await _taskApiService.getUserTasks();
      _errorMessage = '';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('❌ Erreur chargement tâches: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Créer une nouvelle tâche
  Future<void> createTask(TaskModel task) async {
    _setLoading(true);
    try {
      final newTask = await _taskApiService.createTask(task);
      
      // IMPORTANT: Ne pas ajouter directement à la liste, attendre la réponse de l'API
      // et recharger les tâches pour avoir les données fraîches
      await loadUserTasks();
      
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Mettre à jour une tâche
  Future<void> updateTask(String taskId, TaskModel task) async {
    _setLoading(true);
    try {
      await _taskApiService.updateTask(taskId, task);
      
      // Recharger les tâches pour avoir les données fraîches
      await loadUserTasks();
      
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Mettre à jour le statut d'une tâche
  Future<void> updateTaskStatus(String taskId, String status) async {
    try {
      await _taskApiService.updateTaskStatus(taskId, status);
      
      // Recharger les tâches pour avoir les données fraîches
      await loadUserTasks();
      
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Mettre à jour la priorité d'une tâche
  Future<void> updateTaskPriority(String taskId, String priority) async {
    try {
      await _taskApiService.updateTaskPriority(taskId, priority);
      
      // Recharger les tâches pour avoir les données fraîches
      await loadUserTasks();
      
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(String taskId) async {
    _setLoading(true);
    try {
      await _taskApiService.deleteTask(taskId);
      
      // Recharger les tâches pour avoir les données fraîches
      await loadUserTasks();
      
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Rechercher des tâches
  List<TaskModel> searchTasks(String query) {
    if (query.isEmpty) return _tasks;
    
    return _tasks.where((task) {
      final title = task.title?.toLowerCase() ?? '';
      final description = task.description?.toLowerCase() ?? '';
      final searchTerm = query.toLowerCase();
      
      return title.contains(searchTerm) || description.contains(searchTerm);
    }).toList();
  }

  // Filtrer les tâches par statut
  List<TaskModel> filterTasksByStatus(String status) {
    if (status == 'Toutes') return _tasks;
    
    return _tasks.where((task) {
      return task.status?.label.toLowerCase() == status.toLowerCase();
    }).toList();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}