import 'package:flutter/material.dart';

class ComptePage extends StatefulWidget {
  const ComptePage({super.key});

  @override
  State<ComptePage> createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  String _username = "Coumba"; // Nom actuel par défaut
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = _username; // pré-remplir avec le nom actuel
  }

  void _saveUsername() {
    setState(() {
      _username = _controller.text;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nom d'utilisateur mis à jour : $_username")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Compte"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar utilisateur
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/images/profil.jpg"),
            ),
            const SizedBox(height: 20),

            // Champ pour modifier le nom
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Nom d'utilisateur",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            // Bouton Enregistrer
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.save),
              label: const Text("Enregistrer"),
              onPressed: _saveUsername,
            ),

            const SizedBox(height: 30),

            // Affichage du nouveau nom
            Text(
              "Nom actuel : $_username",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
