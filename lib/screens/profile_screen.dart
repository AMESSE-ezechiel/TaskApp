import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          Icon(Icons.emoji_emotions_outlined, color: Colors.amber),
                        ],
                      )
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

                            // Champs du formulaire
                            TextField(
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

                            TextField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 🔵 Bouton Modifier (bleu)
                            ElevatedButton(
                              onPressed: () {
                                // ✅ Affichage du SnackBar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Profil mis à jour avec succès !',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.indigo,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo.shade700,
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Modifier',
                                style: TextStyle(
                                  color: Colors.white, // ✅ Texte en blanc
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
                              child: const Text(
                                'V',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),

                            // 🟡 Bouton blanc sous l’avatar
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Bouton de modification de l’avatar cliqué.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.black87,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shadowColor: Colors.grey,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Modifier'),
                            ),
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
