
import 'package:flutter/material.dart';
import 'package:task_app/Models/users.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel userData;
  const DashboardScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1;
  String _selectedFilter = 'En attente';
  bool _showFilterMenu = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9FA6B0),
      body: Stack(
        children: [
          Column(
            children: [
              // Header section
              Container(
                color: const Color(0xFF9FA6B0),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Search and filter section
                    
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Recherche des tâches',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey.shade500,
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showFilterMenu = !_showFilterMenu;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Toutes',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    
   
                    const SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 32,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Tableau de bord',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gérer vos tâches efficacement',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black.withOpacity(0.7),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Nouvelle tâche'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4A5FC1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Empty state
              Expanded(
                child: Center(
                  child: Text(
                    'Aucune tâche',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Filter dropdown menu overlay
          if (_showFilterMenu)
            Positioned(
              top: 88,
              right: 40,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFilterOption('En attente', isFirst: true),
                        _buildFilterOption('En cours'),
                        _buildFilterOption('Terminer', isLast: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String title, {bool isFirst = false, bool isLast = false}) {
    bool isSelected = _selectedFilter == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = title;
          _showFilterMenu = false;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A5FC1) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: isFirst ? const Radius.circular(8) : Radius.zero,
            topRight: isFirst ? const Radius.circular(8) : Radius.zero,
            bottomLeft: isLast ? const Radius.circular(8) : Radius.zero,
            bottomRight: isLast ? const Radius.circular(8) : Radius.zero,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.white : const Color(0xFF5A5A5A),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
