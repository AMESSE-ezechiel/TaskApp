import 'package:flutter/material.dart';
import 'package:task_app/Models/users.dart';
import 'package:task_app/Screens/page_profile.dart';
import 'package:task_app/Screens/profile.dart';
import 'package:task_app/Screens/statistics.dart';
import 'package:task_app/Screens/tasks.dart';

class NavigationService {
  List<BottomNavigationBarItem> getNavigationItems() {
        return [
          BottomNavigationBarItem(
            icon: Icon(Icons.donut_small),
            label: 'Statictique',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Tâches'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ];
    }

  List<Widget> getScreens(UserModel userData) {
     // student/user
        return _getScreens(userData);
    }


  List<String> getScreenLabels() {
{
        return ['Statictique', 'Tâche', 'Profil'];
    }
  }

  List<Widget> _getScreens(UserModel userData) {
    return [
      StatisticsScreen(userData: userData),
      DashboardScreen(userData: userData),
      PageProfile(userData: userData),
    ];
  }

 
  }

  Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Fonctionnalité en développement',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

