import 'package:flutter/material.dart';

class CommonUserHomeScreen extends StatefulWidget {
  const CommonUserHomeScreen({super.key});

  @override
  State<CommonUserHomeScreen> createState() => _CommonUserHomeScreenState();
}

class _CommonUserHomeScreenState extends State<CommonUserHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pantalla de Usuario')),
      body: const Center(child: Text('¡Bienvenida, Usuario!')),
    );
  }
}
