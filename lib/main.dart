import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Providers/auth.dart';
import 'package:task_app/auth/register_page.dart';
import 'auth/login_page.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
      ),
      debugShowCheckedModeBanner: false,
      // Register named routes
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        // add other routes here, e.g. '/register': (context) => const RegisterPage(),
      },
    );
  }
}
