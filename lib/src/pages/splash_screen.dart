import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/main.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/home_screen.dart';
import 'package:registro_anecdotico/src/pages/common_user/common_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    // Breve delay para mostrar el logo
    await Future.delayed(const Duration(seconds: 2));

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario != null) {
      // Usuario logueado → cargar datos de Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .get();

      final data = doc.data();

      if (data != null) {
        // Aplicar tema guardado
        final tema = data['tema'] ?? 'light';
        MyApp.of(
          context,
        )?.changeTheme(tema == 'dark' ? ThemeMode.dark : ThemeMode.light);

        // Redirigir según rol
        final rol = data['rol'] ?? '';
        if (!mounted) return;

        if (rol.toLowerCase() == 'administrador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminUserHomeScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CommonUserHomeScreen(),
            ),
          );
        }
      } else {
        // No hay datos → ir a HomeScreen
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // Usuario no logueado → ir a HomeScreen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA81515),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Image(
              image: AssetImage("assets/book.png"),
              width: 250,
              height: 250,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/main.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/home_screen.dart';
import 'package:registro_anecdotico/src/pages/common_user/common_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    await Future.delayed(const Duration(seconds: 2)); // breve delay

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario != null) {
      // Usuario logueado, cargamos datos de Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .get();
      final data = doc.data();

      if (data != null) {
        // Aplicar tema
        final tema = data['tema'] ?? 'light';
        MyApp.of(
          context,
        )?.changeTheme(tema == 'dark' ? ThemeMode.dark : ThemeMode.light);

        // Redirigir según rol
        final rol = data['rol'] ?? '';
        if (!mounted) return;
        if (rol == 'administrador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminUserHomeScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CommonUserHomeScreen(),
            ),
          );
        }
      } else {
        // No hay datos en Firestore, ir a HomeScreen
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // Usuario no logueado, ir a HomeScreen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
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
}*/
