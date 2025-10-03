import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ComptePage extends StatefulWidget {
  const ComptePage({super.key}
      );
  @override
  State<ComptePage> createState() => _ComptePageState();
}
class _ComptePageState extends State<ComptePage> {
  final TextEditingController _controller = TextEditingController();
  User? _user;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _controller.text = _user?.displayName ?? '';
  }
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile =
    await _picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      }
      );
      await _uploadAvatar();
    }
  }
  Future<void> _uploadAvatar() async {
    if (_imageFile == null || _user == null) return;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('${_user!.uid}.png');
      await ref.putFile(_imageFile!);
      final photoURL = await ref.getDownloadURL();

      await _user!.updatePhotoURL(photoURL);
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Avatar mis à jour avec succès !"),
          backgroundColor: Colors.blueGrey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'upload : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  Future<void> _saveUsername() async {
    if (_controller.text.trim().isEmpty || _user == null) return;
    try {
      await _user!.updateDisplayName(_controller.text.trim());
      await _user!.reload();
      _user = FirebaseAuth.instance.currentUser;
      setState(() {
        _controller.text = _user?.displayName ?? '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nom mis à jour : ${_user?.displayName}"),
          backgroundColor: Colors.grey,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la mise à jour : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final displayName = _user?.displayName ?? "Utilisateur";
    final photoURL = _user?.photoURL;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Mon Compte"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7966F5),
                         Color(0xFFB870FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider
                            : photoURL != null
                            ? NetworkImage(photoURL)
                            : const AssetImage("assets/img/profil1.png")
                        as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: PopupMenuButton(
                            icon: const Icon(Icons.edit, color: Colors.purple),
                            itemBuilder: (context) => [
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
                              if (value == 'camera') {
                                _pickImage(ImageSource.camera);
                              }
                              if (value == 'gallery') {
                                _pickImage(ImageSource.gallery);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: "Nom d'utilisateur",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon:
                            const Icon(Icons.person, color: Colors.purple),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: 200,
                          height: 55,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              "Enregistrer",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: _saveUsername,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Nom actuel : $displayName",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
