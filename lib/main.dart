import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Models/users.dart';
import 'package:task_app/Providers/auth.dart';
import 'package:task_app/Providers/task.dart';
import 'package:task_app/Screens/page_profile.dart';
import 'package:task_app/Screens/profile.dart';
import 'package:task_app/Screens/tasks.dart';
import 'package:task_app/auth/register_page.dart';
import 'package:task_app/home.dart';
import 'auth/login_page.dart';
import 'splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (context) => TaskProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, taskProvider) {
            return TaskProvider(authProvider);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Register named routes
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/task': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return DashboardScreen(userData: args as UserModel);
        },
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return MainScreen(userData: args as UserModel);
        },
        '/profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return PageProfile(userData: args as UserModel);
        },
        '/profile_edit': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return ProfileScreen(userData: args as UserModel);
        },
      },
    );
  }
}