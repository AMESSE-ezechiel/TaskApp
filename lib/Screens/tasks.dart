import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Models/task_model.dart';
import 'package:task_app/Models/users.dart';
import 'package:task_app/Providers/task.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel userData;
  const DashboardScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- ÉTAT DU WIDGET ---
  int _selectedIndex = 1;
  String _selectedFilter = 'Toutes';
  bool _showFilterDropdown = false;
  final TextEditingController _searchController = TextEditingController();

  // Liste des filtres disponibles
  final List<String> _filters = [
    'Toutes',
    'En attente',
    'En cours',
    'Terminé',
    'Annulé',
  ];

  @override
  void initState() {
    super.initState();
    // Charger les tâches au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.loadUserTasks();
    });
  }

  // --- LOGIQUE DE FILTRAGE ---
  List<TaskModel> get _filteredTasks {
    final taskProvider = Provider.of<TaskProvider>(context);
    List<TaskModel> filtered = List<TaskModel>.from(taskProvider.tasks);

    if (_selectedFilter != 'Toutes') {
      filtered = filtered.where((task) {
        final statusLabel = task.status?.label ?? '';
        return statusLabel == _selectedFilter;
      }).toList();
    }

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        return (task.title ?? '').toLowerCase().contains(searchQuery) ||
            (task.description ?? '').toLowerCase().contains(searchQuery);
      }).toList();
    }

    return filtered;
  }

  // --- DIALOGUES ---

  // Affiche la modale pour ajouter une nouvelle tâche
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

                      // Fermer le dialogue immédiatement
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

  // --- WIDGETS DE CONSTRUCTION ---

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

  // Icône pour chaque filtre
  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Toutes':
        return Icons.list;
      case 'En attente':
        return Icons.schedule;
      case 'En cours':
        return Icons.play_arrow;
      case 'Terminé':
        return Icons.check_circle;
      case 'Annulé':
        return Icons.cancel;
      default:
        return Icons.filter_list;
    }
  }

  // Couleur pour chaque filtre
  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'Toutes':
        return const Color(0xFF4A5FC1);
      case 'En attente':
        return Colors.blue;
      case 'En cours':
        return Colors.orange;
      case 'Terminé':
        return Colors.green;
      case 'Annulé':
        return Colors.red;
      default:
        return Colors.grey;
    }
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

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final displayedTasks = _filteredTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: _showNewTaskDialog,
        tooltip: 'Nouvelle tâche',
        backgroundColor: const Color(0xFF4A5FC1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte de recherche et filtre
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Recherche des tâches',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey[500],
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bouton de filtre amélioré
                      InkWell(
                        onTap: () => setState(
                          () => _showFilterDropdown = !_showFilterDropdown,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A5FC1),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4A5FC1).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getFilterIcon(_selectedFilter),
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedFilter,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _showFilterDropdown
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tableau de bord',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gérer vos tâches efficacement',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                    // Le bouton a été remplacé par le FAB
                  ],
                ),
                const SizedBox(height: 24),

                // Indicateur de chargement
                if (taskProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (displayedTasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.assignment, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Aucune tâche à afficher',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Appuyez sur le bouton + pour créer votre première tâche',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedTasks.length,
                    itemBuilder: (context, index) {
                      final task = displayedTasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () =>
                              _showTaskDetailsDialog(task, index, taskProvider),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.flag,
                                  color: _getPriorityColor(task.priority),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title ?? 'Sans titre',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (task.description != null &&
                                          task.description!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          task.description!,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          task.status,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        task.status?.label ?? 'Inconnu',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _getStatusColor(task.status),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 20,
                                      ),
                                      onSelected: (value) => _handleMenuAction(
                                        value,
                                        task,
                                        taskProvider,
                                      ),
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
                                              const Text(
                                                'Marquer comme terminée',
                                              ),
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
                                              Icon(
                                                Icons.flag,
                                                color: Colors.red.shade700,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('Priorité élevée'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'medium_priority',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.flag,
                                                color: Colors.amber.shade700,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('Priorité moyenne'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'low_priority',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.flag,
                                                color: Colors.green.shade700,
                                              ),
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
                                              Icon(
                                                Icons.edit,
                                                color: Colors.blue.shade700,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('Modifier la tâche'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red.shade700,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text('Supprimer'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // Menu de filtre amélioré
          if (_showFilterDropdown)
            Positioned(
              top: 82,
              right: 20,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // En-tête du menu
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A5FC1).withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.filter_list,
                              color: Color(0xFF4A5FC1),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Filtrer par statut',
                              style: TextStyle(
                                color: Color(0xFF4A5FC1),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ..._filters
                          .map((filter) => _buildFilterOption(filter))
                          .toList(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showTaskDetailsDialog(
    TaskModel task,
    int index,
    TaskProvider provider,
  ) {
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

  Widget _buildFilterOption(String filter) {
    final isSelected = _selectedFilter == filter;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
          _showFilterDropdown = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? _getFilterColor(filter).withOpacity(0.1)
              : Colors.transparent,
          border: isSelected
              ? Border(
                  left: BorderSide(color: _getFilterColor(filter), width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              _getFilterIcon(filter),
              color: _getFilterColor(filter),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: _getFilterColor(filter), size: 18),
          ],
        ),
      ),
    );
  }
}
