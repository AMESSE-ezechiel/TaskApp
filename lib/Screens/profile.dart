import 'package:flutter/material.dart';
import 'package:task_app/Models/users.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userData;
  const ProfileScreen({super.key, required this.userData});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //  Déclaration des contrôleurs
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 📝 Valeurs initiales (optionnel)
    _nameController.text = widget.userData.name.toString();
    _emailController.text = widget.userData.email.toString();
  }

  @override
  void dispose() {
    //  Libération de la mémoire (IMPORTANT !)
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
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
                  'Bonjour,',
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Color(0xFFE8C547),
                  radius: 16,
                  child: Text(
                    widget.userData != null && widget.userData.name != ''
                        ? widget.userData.name![0].toUpperCase()
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
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Motifs de fond (cercles décoratifs)
          Positioned(
            top: -80,
            left: -60,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white.withOpacity(0.7),
            ),
          ),
          Positioned(
            top: 40,
            right: -70,
            child: CircleAvatar(
              radius: 90,
              backgroundColor: Colors.white.withOpacity(0.7),
            ),
          ),
          Positioned(
            bottom: -60,
            left: 0,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withOpacity(0.7),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // En-tête
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TRASKER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Row(
                        children: const [
                          Text('Bonjour, ', style: TextStyle(fontSize: 14)),
                          Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Carte principale
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 300,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blueAccent.shade100),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 50),

                            //  TextField avec contrôleur
                            TextField(
                              controller:
                                  _nameController, //  Ajout du contrôleur
                              decoration: InputDecoration(
                                labelText: 'Nom complet',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 15),

                            //  TextField avec contrôleur
                            TextField(
                              controller:
                                  _emailController, //  Ajout du contrôleur
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 15),

                            //  TextField avec contrôleur
                            TextField(
                              controller:
                                  _passwordController, //  Ajout du contrôleur
                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 🔵 Bouton Modifier
                            ElevatedButton(
                              onPressed: () {
                                // 📖 Récupération des valeurs
                                String name = _nameController.text;
                                String email = _emailController.text;

                                //  Affichage des valeurs
                                print('Nom: $name');
                                print('Email: $email');

                                //  Affichage du SnackBar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Profil mis à jour: $name - $email',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: Colors.indigo,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.shade700,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Modifier',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Avatar au-dessus de la carte
                      Positioned(
                        top: -50,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.amber.shade700,
                              child: Text(
                                widget.userData.name.toString().substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
