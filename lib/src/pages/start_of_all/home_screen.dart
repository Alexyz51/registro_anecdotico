import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String hexColor = '#8e0b13';
    int colorValue = int.parse(hexColor.substring(1), radix: 16);
    Color miColor = Color(colorValue | 0xFF000000);
    const cremita = Color.fromARGB(255, 247, 231, 227);
    const rojoOscuro = Color.fromARGB(255, 39, 2, 2);
    //Paleta de colores habitual

    return Scaffold(
      backgroundColor: miColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/book.png', height: 100),
            const SizedBox(height: 25),
            Text(
              'REGISTRO',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: cremita,
              ),
            ),
            Text(
              'ANECDÓTICO',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: cremita,
              ),
            ),
            const SizedBox(height: 25),
            // Botón Iniciar sesión mas angosto
            SizedBox(
              width: 250, // ancho reducido
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 253, 232, 226),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Iniciar sesión",
                  style: TextStyle(color: rojoOscuro),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Botón Registrarse mas angosto
            SizedBox(
              width: 253.2, // ancho reducido
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'register');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: cremita),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Registrarse",
                  style: TextStyle(color: cremita),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
