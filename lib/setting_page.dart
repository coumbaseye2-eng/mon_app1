import 'package:flutter/material.dart';
import 'package:mon_app1/compte_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  bool _notifEnabled = true;
  bool _darkMode = false;
  String _selectedLang = "Français";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        title: const Text("Paramètres"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7966F5), Color(0xFFB870FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                const CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.settings, size: 50, color: Colors.purple),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
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
                          });
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
