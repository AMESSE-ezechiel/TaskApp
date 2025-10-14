import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Providers/auth.dart';
import 'package:task_app/Providers/task.dart';
import 'package:task_app/Screens/tasks.dart';
import 'package:task_app/auth/register_page.dart';
import 'auth/login_page.dart';
import 'splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (context) => TaskProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
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
          return DashboardScreen(userData: args);
        },
        // add other routes here, e.g. '/register': (context) => const RegisterPage(),
      },

     

    );
  }
}
