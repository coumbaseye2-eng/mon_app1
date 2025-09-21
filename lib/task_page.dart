import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/task.dart';

class TachesPage extends StatefulWidget {
  const TachesPage({super.key});

  @override
  _TachesPageState createState() => _TachesPageState();
}

class _TachesPageState extends State<TachesPage> {
  final CollectionReference tasksRef =
  FirebaseFirestore.instance.collection("tasks");

  late TextEditingController titreCtrl;
  late TextEditingController contenuCtrl;
  late String priorite;
  late DateTime date;

  @override
  void initState() {
    titreCtrl = TextEditingController();
    contenuCtrl = TextEditingController();
    priorite = "Moyenne";
    date = DateTime.now();
    super.initState();
  }
  void _addTask() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nouvelle tâche"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titreCtrl,
                  decoration: const InputDecoration(labelText: "Titre"),
                ),
                TextField(
                  controller: contenuCtrl,
                  decoration: const InputDecoration(labelText: "Contenu"),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: priorite,
                  items: ["Élevée", "Moyenne", "Basse"].map((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      priorite = value!;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      date = picked;
                    }
                  },
                  child: const Text("Choisir une date"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (titreCtrl.text.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    final newTask = Task(
                      titre: titreCtrl.text,
                      contenu: contenuCtrl.text,
                      date: date,
                      priorite: priorite,
                      couleur: priorite == "Élevée"
                          ? Colors.blueAccent
                          : priorite == "Moyenne"
                          ? Colors.purple
                          : Colors.green,
                    );

                    await tasksRef.add({
                      ...newTask.toMap(),
                      "userId": user.uid,
                    }
                    );
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }
  Future<void> _removeTask(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer la tâche ?"),
        content: const Text("Voulez-vous vraiment supprimer cette tâche ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm) {
      await tasksRef.doc(id).delete();
    }
  }

  Future<void> _toggleComplete(Task task) async {
    await tasksRef.doc(task.id).update({"completer": !task.completer});
  }

  void _editTask(Task task) {
    TextEditingController titreCtrl = TextEditingController(text: task.titre);
    TextEditingController contenuCtrl =
    TextEditingController(text: task.contenu);
    String priorite = task.priorite;
    DateTime date = task.date;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier la tâche"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titreCtrl,
                  decoration: const InputDecoration(labelText: "Titre"),
                ),
                TextField(
                  controller: contenuCtrl,
                  decoration: const InputDecoration(labelText: "Contenu"),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: priorite,
                  items: ["Élevée", "Moyenne", "Basse"].map((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      priorite = value!;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      date = picked;
                    }
                  },
                  child: const Text("Choisir une date"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (titreCtrl.text.isNotEmpty) {
                  final updatedTask = Task(
                    id: task.id,
                    titre: titreCtrl.text,
                    contenu: contenuCtrl.text,
                    date: date,
                    priorite: priorite,
                    couleur: priorite == "Élevée"
                        ? Colors.blueAccent
                        : priorite == "Moyenne"
                        ? Colors.purple
                        : Colors.green,
                    completer: task.completer,
                  );

                  await tasksRef.doc(task.id).update(updatedTask.toMap());
                  Navigator.pop(context);
                }
              },
              child: const Text("Modifier"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Tâches"),
        backgroundColor: Colors.green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: user == null
          ? const Center(child: Text("Veuillez vous connecter"))
          : StreamBuilder<QuerySnapshot>(
        stream: tasksRef
            .where("userId", isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucune tâche pour le moment"));
          }
          final tasks = snapshot.data!.docs.map((doc) {
            return Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
          }
          ).toList();
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Card(
                color: task.couleur.withOpacity(0.2),
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(
                    task.titre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: task.completer
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(
                      "${task.contenu}\nDate: ${task.date.toLocal()} \nPriorité: ${task.priorite}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          task.completer
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: task.completer ? Colors.green : Colors.black,
                        ),
                        onPressed: () => _toggleComplete(task),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _editTask(task),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTask(task.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
