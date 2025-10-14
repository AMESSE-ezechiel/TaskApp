import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Providers/auth.dart';
import 'package:task_app/auth/register_page.dart';
import 'auth/login_page.dart';
import 'splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // ChangeNotifierProvider(
        //   create: (context) => StatisticsProvider(
        //     Provider.of<AuthProvider>(context, listen: false),
        //   ),
        // ),
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        // add other routes here, e.g. '/register': (context) => const RegisterPage(),
      },

      home: SplashScreen(),

    );
  }
}
