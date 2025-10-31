import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Models/task_model.dart';
import 'package:task_app/Models/users.dart';
import 'package:task_app/Providers/task.dart';

class StatisticsScreen extends StatefulWidget {
  final UserModel userData;
  const StatisticsScreen({super.key, required this.userData});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.loadUserTasks();
    });
  }

  void _showNewTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskStatus? taskStatus = TaskStatus.EN_ATTENTE;
    TaskPriority? taskPriority = TaskPriority.BASSE;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Nouvelle tâche',
                style: TextStyle(
                  color: Color(0xFF4A5FC1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                        hintText: 'Entrez le titre',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Entrez la description',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskStatus>(
                      value: taskStatus,
                      decoration: const InputDecoration(labelText: 'Statut'),
                      items: TaskStatus.values
                          .map(
                            (value) => DropdownMenuItem<TaskStatus>(
                              value: value,
                              child: Text(value.label),
                            ),
                          )
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setDialogState(() => taskStatus = newValue);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskPriority>(
                      value: taskPriority,
                      decoration: const InputDecoration(labelText: 'Priorité'),
                      items: TaskPriority.values
                          .map(
                            (value) => DropdownMenuItem<TaskPriority>(
                              value: value,
                              child: Text(value.label),
                            ),
                          )
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setDialogState(() => taskPriority = newValue);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                // ... dans la méthode _showNewTaskDialog
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final taskProvider = Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      );
                      final newTask = TaskModel(
                        title: titleController.text,
                        description: descriptionController.text,
                        status: taskStatus,
                        priority: taskPriority,
                        userId: widget.userData.id,
                      );

                      Navigator.pushReplacementNamed(context, '/home', arguments: widget.userData);

                      // Afficher un indicateur de chargement
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Création de la tâche en cours...'),
                            ],
                          ),
                          backgroundColor: Colors.blue,
                          duration: Duration(seconds: 5),
                        ),
                      );

                      // Créer la tâche
                      taskProvider
                          .createTask(newTask)
                          .then((_) {
                            // Le SnackBar sera automatiquement remplacé par le rechargement
                          })
                          .catchError((error) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $error'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5FC1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 245, 255),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return _buildLoadingIndicator();
          }

          if (taskProvider.hasError) {
            return _buildErrorWidget(taskProvider.errorMessage, taskProvider);
          }

          return _buildStatisticsContent(taskProvider);
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FAB pour actualiser
          FloatingActionButton(
            heroTag: 'refresh_fab',
            onPressed: _loadStatistics,
            tooltip: 'Actualiser',
            backgroundColor: const Color.fromARGB(255, 74, 111, 165),
            mini: true,
            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 10),
          // FAB principal pour créer une tâche
          FloatingActionButton(
            heroTag: 'add_task_fab',
            onPressed: _showNewTaskDialog,
            tooltip: 'Nouvelle tâche',
            backgroundColor: const Color(0xFF4A5FC1),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Chargement des statistiques...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage, TaskProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                provider.clearError();
                _loadStatistics();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsContent(TaskProvider provider) {
    final tasks = provider.tasks;

    return RefreshIndicator(
      onRefresh: () async => _loadStatistics(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserHeader(),
            const SizedBox(height: 20),
            _buildStatsGrid(provider),
            const SizedBox(height: 20),
            _buildRecentTasks(tasks, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color.fromARGB(255, 74, 111, 165),
              child: Text(
                widget.userData.name.toString().substring(0, 1).toUpperCase() ??
                    'U',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userData.name.toString() ?? 'Utilisateur',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(widget.userData.email.toString() ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(TaskProvider provider) {
    final totalTasks = provider.tasks.length;
    final pendingTasks = provider.pendingTasks.length;
    final inProgressTasks = provider.inProgressTasks.length;
    final completedTasks = provider.completedTasks.length;
    final completionRate = totalTasks > 0
        ? (completedTasks / totalTasks * 100)
        : 0;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildStatCard('Total des tâches', '$totalTasks', Icons.assignment),
        _buildStatCard('En attente', '$pendingTasks', Icons.schedule),
        _buildStatCard('En cours', '$inProgressTasks', Icons.play_arrow),
        _buildStatCard('Terminées', '$completedTasks', Icons.check_circle),
        _buildStatCard(
          'Taux de complétion',
          '${completionRate.toStringAsFixed(1)}%',
          Icons.trending_up,
        ),
        _buildStatCard('En retard', '0', Icons.warning),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color.fromARGB(255, 74, 111, 165),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTasks(List<TaskModel> tasks, TaskProvider provider) {
    final recentTasks = tasks.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tâches récentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (recentTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.assignment, size: 48, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'Aucune tâche récente',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Appuyez sur le bouton + pour créer une tâche',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentTasks.map(
                (task) => ListTile(
                  leading: Icon(
                    Icons.assignment,
                    color: _getStatusColor(task.status),
                  ),
                  title: Text(task.title ?? 'Sans titre'),
                  subtitle: Text('Statut: ${task.status?.label ?? 'Inconnu'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                            task.priority,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getPriorityColor(task.priority),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          task.priority?.label ?? '',
                          style: TextStyle(
                            color: _getPriorityColor(task.priority),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onSelected: (value) =>
                            _handleMenuAction(value, task, provider),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'mark_completed',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text('Marquer comme terminée'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'mark_in_progress',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text('Marquer en cours'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'mark_pending',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                const Text('Marquer en attente'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'high_priority',
                            child: Row(
                              children: [
                                Icon(Icons.flag, color: Colors.red.shade700),
                                const SizedBox(width: 8),
                                const Text('Priorité élevée'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'medium_priority',
                            child: Row(
                              children: [
                                Icon(Icons.flag, color: Colors.amber.shade700),
                                const SizedBox(width: 8),
                                const Text('Priorité moyenne'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'low_priority',
                            child: Row(
                              children: [
                                Icon(Icons.flag, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                const Text('Priorité basse'),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                const Text('Modifier la tâche'),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red.shade700),
                                const SizedBox(width: 8),
                                const Text('Supprimer'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    _showTaskDetails(task, provider);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(TaskModel task, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            task.title ?? 'Sans titre',
            style: const TextStyle(
              color: Color(0xFF4A5FC1),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                (task.description == null || task.description!.isEmpty)
                    ? 'Aucune description'
                    : task.description!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Statut: ${task.status?.label ?? 'Non défini'}',
                      style: TextStyle(
                        color: _getStatusColor(task.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Priorité: ${task.priority?.label ?? 'Non définie'}',
                      style: TextStyle(
                        color: _getPriorityColor(task.priority),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditTaskDialog(task, provider);
              },
              child: const Text('Modifier'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(task, provider);
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _handleMenuAction(String action, TaskModel task, TaskProvider provider) {
    switch (action) {
      case 'mark_completed':
        _updateTaskStatus(task, TaskStatus.TERMINE, provider);
        break;
      case 'mark_in_progress':
        _updateTaskStatus(task, TaskStatus.EN_COURS, provider);
        break;
      case 'mark_pending':
        _updateTaskStatus(task, TaskStatus.EN_ATTENTE, provider);
        break;
      case 'high_priority':
        _updateTaskPriority(task, TaskPriority.ELEVE, provider);
        break;
      case 'medium_priority':
        _updateTaskPriority(task, TaskPriority.MOYENNE, provider);
        break;
      case 'low_priority':
        _updateTaskPriority(task, TaskPriority.BASSE, provider);
        break;
      case 'edit':
        _showEditTaskDialog(task, provider);
        break;
      case 'delete':
        _showDeleteConfirmation(task, provider);
        break;
    }
  }

  void _updateTaskStatus(
    TaskModel task,
    TaskStatus newStatus,
    TaskProvider provider,
  ) {
    provider
        .updateTaskStatus(task.id.toString(), newStatus.value)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Statut mis à jour: ${newStatus.label}'),
              backgroundColor: Colors.green,
            ),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  void _updateTaskPriority(
    TaskModel task,
    TaskPriority newPriority,
    TaskProvider provider,
  ) {
    provider
        .updateTaskPriority(task.id.toString(), newPriority.value)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Priorité mise à jour: ${newPriority.label}'),
              backgroundColor: Colors.green,
            ),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  void _showEditTaskDialog(TaskModel task, TaskProvider provider) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    TaskStatus? taskStatus = task.status;
    TaskPriority? taskPriority = task.priority;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Modifier la tâche',
                style: TextStyle(
                  color: Color(0xFF4A5FC1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Titre'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskStatus>(
                      value: taskStatus,
                      decoration: const InputDecoration(labelText: 'Statut'),
                      items: TaskStatus.values
                          .map(
                            (status) => DropdownMenuItem<TaskStatus>(
                              value: status,
                              child: Text(status.label),
                            ),
                          )
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setDialogState(() => taskStatus = newValue);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<TaskPriority>(
                      value: taskPriority,
                      decoration: const InputDecoration(labelText: 'Priorité'),
                      items: TaskPriority.values
                          .map(
                            (priority) => DropdownMenuItem<TaskPriority>(
                              value: priority,
                              child: Text(priority.label),
                            ),
                          )
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setDialogState(() => taskPriority = newValue);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final updatedTask = task.copyWith(
                        title: titleController.text,
                        description: descriptionController.text,
                        status: taskStatus,
                        priority: taskPriority,
                      );

                      provider
                          .updateTask(task.id.toString(), updatedTask)
                          .then((_) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Tâche mise à jour avec succès',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          })
                          .catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur: $error'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5FC1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Sauvegarder'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(TaskModel task, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer la tâche "${task.title}" ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                provider
                    .deleteTask(task.id.toString())
                    .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Tâche supprimée avec succès'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    })
                    .catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(TaskStatus? status) {
    switch (status) {
      case TaskStatus.EN_COURS:
        return Colors.orange;
      case TaskStatus.TERMINE:
        return Colors.green;
      case TaskStatus.ANNULE:
        return Colors.red;
      case TaskStatus.EN_ATTENTE:
      default:
        return Colors.blue;
    }
  }

  Color _getPriorityColor(TaskPriority? priority) {
    switch (priority) {
      case TaskPriority.ELEVE:
        return Colors.red;
      case TaskPriority.MOYENNE:
        return Colors.amber.shade700;
      case TaskPriority.BASSE:
        return Colors.green;
      case TaskPriority.INDIFFERENT:
      default:
        return Colors.grey;
    }
  }
}
