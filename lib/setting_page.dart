import 'package:flutter/material.dart';
import 'package:mon_app1/compte_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  // ✅ Déclaration des variables d'état
  bool _notifEnabled = true;
  bool _darkMode = false;
  String _selectedLang = "Français";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        children: [
          // Profil utilisateur
          ListTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text("Mon Compte"),
            subtitle: const Text("Gérer mes informations"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComptePage()),
              );
               },
          ),
          const Divider(),

          // Notifications
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.green),
            title: const Text("Notifications"),
            value: _notifEnabled,
            onChanged: (bool value) {
              setState(() {
                _notifEnabled = value;
              });
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.green),
            title: const Text("Mode sombre"),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
              }
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.language, color: Colors.green),
            title: const Text("Langue"),
            subtitle: Text(_selectedLang),
            trailing: DropdownButton<String>(
              value: _selectedLang,
              items: ["Français", "Anglais", "Wolof"]
                  .map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang),
              ))
                  .toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedLang = value!;
                });
              },
            ),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.info, color: Colors.green),
            title: const Text("À propos"),
            subtitle: const Text("Version 1.0.0"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Application de Gestion Tâches",
                applicationVersion: "1.0.0",
                children: [
                  const Text("Développé par Coumba💚"),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
