import 'package:flutter/material.dart';

class HomeButtons extends StatelessWidget {
  final VoidCallback onEscolarBasicaPressed;
  final VoidCallback onNivelMedioPressed;

  const HomeButtons({
    required this.onEscolarBasicaPressed,
    required this.onNivelMedioPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onEscolarBasicaPressed,
          child: const Text('Escolar básica'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: onNivelMedioPressed,
          child: const Text('Nivel medio'),
        ),
      ],
    );
  }
}
