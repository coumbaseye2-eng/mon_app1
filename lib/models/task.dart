import 'package:flutter/material.dart';

class Task {
  String id;
  String titre;
  String contenu;
  DateTime date;
  String priorite;
  Color couleur;
  bool completer;

  Task({
    this.id = "",
    required this.titre,
    required this.contenu,
    required this.date,
    required this.priorite,
    required this.couleur,
    this.completer = false,
  });
  Map<String, dynamic> toMap() {
    return {
      "titre": titre,
      "contenu": contenu,
      "date": date.toIso8601String(),
      "priorite": priorite,
      "couleur": couleur.value,
      "completer": completer,
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> data) {
    return Task(
      id: id,
      titre: data["titre"] ?? "",
      contenu: data["contenu"] ?? "",
      date: DateTime.parse(data["date"]),
      priorite: data["priorite"] ?? "Moyenne",
      couleur: Color(data["couleur"] ?? Colors.grey),
      completer: data["completer"] ?? false,
    );
  }
}