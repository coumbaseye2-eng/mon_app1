import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mon_app1/main.dart';
import 'package:mon_app1/task_page.dart';
import 'package:mon_app1/setting_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 0;
  bool _isEditing = false;
  late TextEditingController _nameController;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }
  Future<void> _updateDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _nameController.text.trim().isNotEmpty) {
      await user.updateDisplayName(_nameController.text.trim());
      await user.reload();
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nom mis à jour avec succès")),
      );
    }
  }
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }
  void _confirmAction({
    required String titre,
    required String message,
    required Future<void> Function() onConfirm,
  }
  )
  {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titre, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await onConfirm();
            },
            child: const Text("Confirmer"),
          ),
        ],
      ),
    );
  }
  void _showAccountOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pop(context);
                _confirmAction(
                  titre: "Déconnexion",
                  message: "Voulez-vous vraiment vous déconnecter ?",
                  onConfirm: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MyHomePage()),
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer le compte'),
              onTap: () {
                Navigator.pop(context);
                _confirmAction(
                  titre: "Supprimer le compte",
                  message: "Cette action est irréversible. Continuer ?",
                  onConfirm: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await user.delete();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MyHomePage()),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Utilisateur non connecté")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (user.photoURL != null
                          ? NetworkImage(user.photoURL!)
                          : const AssetImage("assets/img/OIP.jpg"))
                      as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'camera',
                              child: Row(
                                children: [
                                  Icon(Icons.camera_alt),
                                  SizedBox(width: 8),
                                  Text('Camera'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'gallery',
                              child: Row(
                                children: [
                                  Icon(Icons.photo),
                                  SizedBox(width: 8),
                                  Text('Galerie'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'camera') _pickImage(ImageSource.camera);
                            if (value == 'gallery') _pickImage(ImageSource.gallery);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: _isEditing
                            ? TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: "Nom d'utilisateur",
                          ),
                        )
                            : Center(
                          child: Text(
                            user.displayName ?? "Utilisateur",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isEditing ? Icons.check : Icons.edit),
                        onPressed: () {
                          if (_isEditing) {
                            _updateDisplayName();
                          } else {
                            setState(() => _isEditing = true);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user.email ?? "Email inconnu",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 18),
                ),
                const SizedBox(height: 70),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('tasks')
                      .where('userId', isEqualTo: user.uid)
                      .where('completed', isEqualTo: true)
                      .get(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final completed = snapshot.data!.docs.length;
                    return Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 40, color: Colors.green),
                          const SizedBox(width: 15),
                          Text(
                            "Tâches complétées: $completed",
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 150),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton.extended(
                onPressed: _showAccountOptions,
                backgroundColor: Colors.green[400],
                icon: const Icon(Icons.settings),
                label: const Text("Options"),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.purpleAccent),
            label: "Profil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.purpleAccent),
            label: "Tâches",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.purpleAccent),
            label: "Paramètres",
          ),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TachesPage()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingPage()),
            );
          }
        },
      ),
    );
  }
}
