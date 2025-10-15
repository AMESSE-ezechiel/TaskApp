import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Models/users.dart';
import 'package:task_app/Providers/auth.dart';
import 'package:task_app/Providers/task.dart';
import 'package:task_app/auth/login_page.dart';
import 'package:task_app/layout/navigation.bar.dart';

class MainScreen extends StatefulWidget {
  UserModel? userData;
  MainScreen({super.key, required this.userData});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Charger les tâches au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.loadUserTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    final navigationService = NavigationService();
    final navItems = navigationService.getNavigationItems();
    final screens = navigationService.getScreens(user);
    final labels = navigationService.getScreenLabels();

    return Scaffold(
      backgroundColor: const Color(0xFF7B818A),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'TRASKER',
          style: TextStyle(
            color: Color(0xFF4A5FC1),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  'Bienvenue,',
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Color(0xFFE8C547),
                  radius: 16,
                  child: Text(
                    user != null && user.name != ''
                        ? user.name![0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: () {
              _logout(authProvider);
            },
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: navItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF4A5FC1),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      drawer: _buildDrawer(user, authProvider),
    );
  }

  void _logout(AuthProvider authProvider) async {
    try {
      await authProvider.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la déconnexion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDrawer(UserModel user, AuthProvider authProvider) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name ?? 'Utilisateur'),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user.name?.isNotEmpty == true
                    ? user.name![0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('Nom: ${user.name}'),
          ),
          ListTile(leading: const Icon(Icons.email), title: Text(user.email)),
          const Divider(),
          ..._getCommonDrawerItems(authProvider, user),
        ],
      ),
    );
  }

  List<Widget> _getCommonDrawerItems(
    AuthProvider authProvider,
    UserModel user,
  ) {
    return [
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Déconnexion'),
        onTap: () {
          _logout(authProvider);
        },
      ),
    ];
  }
}