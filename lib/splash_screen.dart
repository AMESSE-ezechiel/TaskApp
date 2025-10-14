import 'dart:async';
import 'package:flutter/material.dart';
import 'auth/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF7B818A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/groupe1.png', width: 180),
            // const SizedBox(height: 16),
          //   const Text(
          //     "TRASKER",
          //     style: TextStyle(
          //       fontSize: 22,
          //       color: Colors.white,
          //       fontWeight: FontWeight.bold,
          //       letterSpacing: 1.5,
          //     ),
          //   ),
          ],
        ),
      ),
    );
  }
}
