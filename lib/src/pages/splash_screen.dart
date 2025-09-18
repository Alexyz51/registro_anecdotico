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
  bool _mostrarColegio = true; // Escudo y nombre colegio
  bool _mostrarRegistro = false; // Logo book.png

  @override
  void initState() {
    super.initState();
    _animarSplash();
    _iniciar();
  }

  Future<void> _animarSplash() async {
    // Mostrar el colegio 2 segundos
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _mostrarColegio = false;
      _mostrarRegistro = true;
    });
  }

  Future<void> _iniciar() async {
    // Delay total antes de navegar
    await Future.delayed(const Duration(seconds: 5));

    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .get();
      final data = doc.data();

      if (data != null) {
        final tema = data['tema'] ?? 'light';
        MyApp.of(
          context,
        )?.changeTheme(tema == 'dark' ? ThemeMode.dark : ThemeMode.light);

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
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Escudo y nombre del colegio
            AnimatedOpacity(
              opacity: _mostrarColegio ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/escudo.png', width: 250, height: 250),
                  //const SizedBox(height: 0),
                  const Text(
                    "Colegio Nacional Profesora María del Carmen Morales de Achucarro",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Logo book.png con texto Registro Anecdótico
            AnimatedOpacity(
              opacity: _mostrarRegistro ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset("assets/book.png", width: 150, height: 150),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
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
}*/

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
