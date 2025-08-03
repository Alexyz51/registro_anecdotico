import 'package:flutter/material.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return; // ✅ Verifica si el widget sigue montado

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 168, 21, 21),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Image(
              image: AssetImage("assets/book.png"),
              width: 250,
              height: 250,
            ),
            SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
