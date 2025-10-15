import 'package:flutter/material.dart';

// MODIFICATION : Ajout de la `priority` au modèle de données.
class Task {
  String title;
  String description;
  String status;
  String priority; // NOUVEAU : Champ pour la priorité

  Task({
    required this.title,
    required this.description,
    this.status = 'En attente',
    this.priority = 'Basse', // NOUVEAU : Valeur par défaut pour la priorité
  });
}

class DashboardScreen extends StatefulWidget {
  final dynamic userData;
  const DashboardScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // --- ÉTAT DU WIDGET ---
  int _selectedIndex = 1;
  String _selectedFilter = 'Toutes';
  bool _showFilterDropdown = false;
  List<Task> _tasks = []; // Liste pour stocker les tâches
  final TextEditingController _searchController = TextEditingController();

  // --- LOGIQUE DE FILTRAGE ---
  List<Task> get _filteredTasks {
    List<Task> filtered = _tasks;

    if (_selectedFilter != 'Toutes') {
      filtered = filtered.where((task) => task.status == _selectedFilter).toList();
    }

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((task) {
        return task.title.toLowerCase().contains(searchQuery) ||
            task.description.toLowerCase().contains(searchQuery);
      }).toList();
    }

    return filtered;
  }

  // --- DIALOGUES ---

  // Affiche la modale pour ajouter une nouvelle tâche
  void _showNewTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String taskStatus = 'En attente';
    String taskPriority = 'Basse'; // NOUVEAU : État pour la priorité

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Nouvelle tâche', style: TextStyle(color: Color(0xFF4A5FC1), fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre', hintText: 'Entrez le titre')),
                    const SizedBox(height: 16),
                    TextField(controller: descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', hintText: 'Entrez la description')),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: taskStatus,
                      decoration: const InputDecoration(labelText: 'Statut'),
                      items: ['En attente', 'En cours', 'Terminer'].map((value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) setDialogState(() => taskStatus = newValue);
                      },
                    ),
                    const SizedBox(height: 16),
                    // NOUVEAU : Champ pour sélectionner la priorité
                    DropdownButtonFormField<String>(
                      value: taskPriority,
                      decoration: const InputDecoration(labelText: 'Priorité'),
                      items: ['Basse', 'Moyenne', 'Haute'].map((value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) setDialogState(() => taskPriority = newValue);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      setState(() {
                        _tasks.add(Task(
                          title: titleController.text,
                          description: descriptionController.text,
                          status: taskStatus,
                          priority: taskPriority, // NOUVEAU : Sauvegarde de la priorité
                        ));
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A5FC1), foregroundColor: Colors.white),
                  child: const Text('Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // NOUVEAU : Dialogue pour modifier une tâche existante
  void _showEditTaskDialog(Task task, int index) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    String taskStatus = task.status;
    String taskPriority = task.priority;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Modifier la tâche', style: TextStyle(color: Color(0xFF4A5FC1), fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre')),
                    const SizedBox(height: 16),
                    TextField(controller: descriptionController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: taskStatus,
                      decoration: const InputDecoration(labelText: 'Statut'),
                      items: ['En attente', 'En cours', 'Terminer'].map((value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) setDialogState(() => taskStatus = newValue);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: taskPriority,
                      decoration: const InputDecoration(labelText: 'Priorité'),
                      items: ['Basse', 'Moyenne', 'Haute'].map((value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) setDialogState(() => taskPriority = newValue);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      setState(() {
                        _tasks[index].title = titleController.text;
                        _tasks[index].description = descriptionController.text;
                        _tasks[index].status = taskStatus;
                        _tasks[index].priority = taskPriority;
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A5FC1), foregroundColor: Colors.white),
                  child: const Text('Sauvegarder'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Affiche les détails d'une tâche (avec options Modifier/Supprimer)
  void _showTaskDetailsDialog(Task task, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(task.title, style: const TextStyle(color: Color(0xFF4A5FC1), fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Text(task.description.isEmpty ? 'Aucune description' : task.description),
              const SizedBox(height: 16),
              Row(
                children: [
                   Text('Statut: ${task.status}', style: const TextStyle(fontWeight: FontWeight.w500)),
                   const SizedBox(width: 16),
                   Text('Priorité: ${task.priority}', style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue de détails
                _showEditTaskDialog(task, index); // Ouvre le dialogue de modification
              },
              child: const Text('Modifier'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _tasks.removeAt(index));
                Navigator.of(context).pop();
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A5FC1), foregroundColor: Colors.white),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En cours': return Colors.orange;
      case 'Terminer': return Colors.green;
      default: return Colors.blue;
    }
  }
  
  // NOUVEAU : Helper pour la couleur et l'icône de priorité
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Haute': return Colors.red;
      case 'Moyenne': return Colors.amber.shade700;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedTasks = _filteredTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('TRASKER', style: TextStyle(color: Color(0xFF4A5FC1), fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          const Center(child: Text('Bonjour,', style: TextStyle(color: Colors.black87, fontSize: 14))),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFFE8C547),
            radius: 16,
            child: Text(
              widget.userData != null && widget.userData['name'] != null && widget.userData['name'].isNotEmpty ? widget.userData['name'][0].toUpperCase() : 'U',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () { /* TODO: Logique de déconnexion */ },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et bouton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tableau de bord', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                        SizedBox(height: 4),
                        Text('Gérer vos tâches efficacement', style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.3)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _showNewTaskDialog,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Nouvelle tâche'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A5FC1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Carte de recherche et filtre
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() {}),
                          decoration: InputDecoration(hintText: 'Recherche des tâches', hintStyle: TextStyle(color: Colors.grey[500]), prefixIcon: Icon(Icons.search, color: Colors.grey[500]), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () => setState(() => _showFilterDropdown = !_showFilterDropdown),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Text(_selectedFilter, style: TextStyle(color: Colors.grey[700])),
                              const SizedBox(width: 8),
                              Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Liste des tâches
                if (displayedTasks.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 80), child: Text('Aucune tâche à afficher', style: TextStyle(fontSize: 18, color: Colors.black54))))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedTasks.length,
                    itemBuilder: (context, index) {
                      final task = displayedTasks[index];
                      final originalIndex = _tasks.indexOf(task);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showTaskDetailsDialog(task, originalIndex),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // NOUVEAU : Affichage de l'icône de priorité
                                Icon(Icons.flag, color: _getPriorityColor(task.priority), size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(task.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      if (task.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(task.description, style: TextStyle(color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: _getStatusColor(task.status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Text(task.status, style: TextStyle(fontSize: 12, color: _getStatusColor(task.status), fontWeight: FontWeight.w600)),
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
          // Menu de filtre
          if (_showFilterDropdown)
            Positioned(
              top: 235,
              right: 20,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: ['Toutes', 'En attente', 'En cours', 'Terminer'].map((filter) => _buildFilterOption(filter)).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF4A5FC1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.donut_small), label: 'Statistique'),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Tâche'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String text) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = text;
          _showFilterDropdown = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: _selectedFilter == text ? Colors.grey[200] : Colors.transparent,
        child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ),
    );
  }
}

