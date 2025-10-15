import 'package:flutter/foundation.dart';
import 'package:task_app/Models/tasks.dart';
import 'package:task_app/Providers/auth.dart';
import 'package:task_app/Services/task.api.dart';

class TaskProvider with ChangeNotifier {
  final TaskApiService _taskApiService;
  final AuthProvider _authProvider;

  TaskModel? _userTask;
  bool _isLoading = false;
  String _errorMessage = '';

  TaskProvider(this._authProvider)
      : _taskApiService = TaskApiService(
          getTokenCallback: () => Future.value(_authProvider.token),
        );

  TaskModel? get userTask => _userTask;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;
  // Remove statistics and leaderboard related getters and fields if not defined in this provider
  // bool get hasStatistics => _userStatistics != null;
  // List<LeaderboardEntry> get leaderboard => _leaderboard;

  Future<void> loadUserTask() async {
    _setLoading(true);
    _errorMessage = '';

    try {
      dynamic userData = _authProvider.currentUser;
      if (userData == null) {
        throw Exception('Utilisateur non authentifié');
      }
      _userTask = await _taskApiService.getUserTasks(userData.id);
      _errorMessage = ''; // Clear error on success
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement de la tâche utilisateur';
      print('❌ Erreur provider task: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  // Méthodes utilitaires pour l'UI
  // Add task-related utility methods here if needed

} 