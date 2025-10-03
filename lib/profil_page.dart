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
class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isEditing = false;
  late TextEditingController _nameController;
  File? _imageFile;
  File? _backgroundImage;
  final ImagePicker _picker = ImagePicker();

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _animationController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }
  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
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
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }
  Future<void> _pickBackgroundImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) setState(() => _backgroundImage = File(pickedFile.path));
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
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Changer le fond'),
              onTap: () {
                Navigator.pop(context);
                _showBackgroundOptions();
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showBackgroundOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Prendre une photo"),
              onTap: () {
                Navigator.pop(context);
                _pickBackgroundImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Choisir depuis la galerie"),
              onTap: () {
                Navigator.pop(context);
                _pickBackgroundImage(ImageSource.gallery);
              },
            ),
            if (_backgroundImage != null)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text("Supprimer le fond"),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _backgroundImage = null);
                },
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }
  )
  {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: color.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            "$count",
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center),
        ],
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
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: _showBackgroundOptions,
              child: Container(
                height: screenHeight * 0.43,
                decoration: BoxDecoration(
                  image: _backgroundImage != null
                      ? DecorationImage(
                    image: FileImage(_backgroundImage!),
                    fit: BoxFit.cover,
                  )
                      : null,
                  gradient: _backgroundImage == null
                      ? const LinearGradient(
                    colors: [Color(0xFF7966F5), Color(0xFFB870FD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
                child: const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.09,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7966F5), Color(0xFFB870FD)],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(120),
                    topRight: Radius.circular(120),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
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
                  Row(
                    children: [
                      Expanded(
                        child: _isEditing
                            ? TextField(
                          controller: _nameController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Nom d'utilisateur",
                            hintStyle: const TextStyle(color: Colors.white70),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        )
                            : Center(
                          child: Text(
                            user.displayName ?? "Utilisateur",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isEditing ? Icons.check : Icons.edit,
                            color: Colors.white),
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
                  const SizedBox(height: 10),
                  Text(
                    user.email ?? "Email inconnu",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 80),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('tasks')
                            .where('userId', isEqualTo: user.uid)
                            .where('completed', isEqualTo: true)
                            .get(),
                        builder: (context, snapshot) {
                          final completed = snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return _buildStatCard(
                            title: "Tâches complétées",
                            count: completed,
                            icon: Icons.check_circle,
                            color: Colors.purple,
                          );
                        },
                      ),
                      FutureBuilder<QuerySnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('tasks')
                            .where('userId', isEqualTo: user.uid)
                            .where('completed', isEqualTo: false)
                            .get(),
                        builder: (context, snapshot) {
                          final pending = snapshot.hasData ? snapshot.data!.docs.length : 0;
                          return _buildStatCard(
                            title: "Tâches en cours",
                            count: pending,
                            icon: Icons.pending_actions,
                            color: Colors.blue,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 16,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animation.value),
                  child: child,
                );
              },
              child: FloatingActionButton.extended(
                onPressed: _showAccountOptions,
                backgroundColor: Colors.purple[400],
                icon: const Icon(Icons.settings),
                label: const Text("Options"),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person,color: Colors.cyanAccent),
              label: "Profil",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list,color: Colors.cyanAccent),
              label: "Tâches",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings,color: Colors.cyanAccent),
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
      ),
    );
  }
}
