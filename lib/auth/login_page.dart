import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_app/Models/users.dart';
import 'package:task_app/Providers/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isVisible = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Stack(
        children: [
          // 🌈 Cercles décoratifs
          Positioned(
            top: -80,
            left: -50,
            child: _buildCircle(180, Colors.purple.withOpacity(0.3)),
          ),
          Positioned(
            bottom: -100,
            right: -70,
            child: _buildCircle(220, Colors.blueAccent.withOpacity(0.2)),
          ),
          Positioned(
            top: 150,
            right: -40,
            child: _buildCircle(120, Colors.pinkAccent.withOpacity(0.15)),
          ),

          // 🧩 Contenu principal centré
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                width: 320,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset('assets/groupe1.png', height: 90),
                    const SizedBox(height: 20),

                    // Titre
                    const Text(
                      "Connexion",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B5998),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Champ Email
                    _buildInputField(
                      label: "Adresse e-mail",
                      icon: Icons.email_outlined,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 20),

                    // Champ Mot de passe
                    _buildInputField(
                      label: "Mot de passe",
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      obscureText: !_isVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _isVisible = !_isVisible);
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Bouton Connexion
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B5998),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        onPressed: () {
                          _validation();
                        },
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lien vers inscription
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Pas encore de compte ? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/register');
                          },
                          child: const Text(
                            "Inscrivez-vous",
                            style: TextStyle(
                              color: Color(0xFF3B5998),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Cercles décoratifs
  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // 🔹 Champs de texte stylisés avec bord coloré et focus
  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3B5998)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(
            color: const Color(0xFF3B5998).withOpacity(0.3),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFF3B5998), width: 2),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _validation() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Veuillez remplir tous les champs.");
      return;
    }

    if (!_emailController.text.contains('@')) {
      _showError("Veuillez entrer une adresse email valide.");
      return;
    }

    // Si toutes les validations passent
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Connexion en cours..."),
        backgroundColor: Colors.green,
      ),
    );
    _login();
  }

  void _login() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final loginUser = UserModel(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final response = await authProvider.login(loginUser);

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        Navigator.pushReplacementNamed(context, '/task', arguments: userData);
      } else {
        _showError('Erreur lors de la connexion');
      }
    } catch (e) {
      _showError('Erreur: $e');
      print('Erreur: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
