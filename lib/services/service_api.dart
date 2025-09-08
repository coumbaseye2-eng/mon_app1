import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  final String baseUrl = "https://jsonplaceholder.typicode.com";

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse("$baseUrl/posts"));
    print("Données reçues : ${response.body}");
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Task(
        id: json["id"].toString(),
        titre: json["title"] ?? "Api",
        contenu: json["body"] ?? "",
        date: DateTime.now(),
        priorite: "Moyenne",
        couleur: const Color(0xFF42A5F5),
      )).toList();
    } else {
      throw Exception("Erreur lors du chargement des données");
    }
  }
}
