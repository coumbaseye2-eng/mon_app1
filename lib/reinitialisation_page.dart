import 'package:flutter/material.dart';

class ReinitialisationPage extends StatelessWidget {
  const ReinitialisationPage({super.key});

  @override
  // ignore: override_on_non_overriding_member
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 243, 142),
        title: const Text('reinitialisation Page'),
      ),
      body: const Center(
        child: Text('reinitialisation Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
