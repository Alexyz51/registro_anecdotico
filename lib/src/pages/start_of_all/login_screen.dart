import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasenia = TextEditingController();
  bool _cargaDeDatos = false;

  Future<void> iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _cargaDeDatos = true;
      });

      final correoFinal = correo.text.trim().toLowerCase();
      final contraseniaFinal = contrasenia.text.trim();

      try {
        final credenciales = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: correoFinal,
              password: contraseniaFinal,
            );

        final uid = credenciales.user!.uid;

        final consulta = await FirebaseFirestore.instance
            .collection('users')
            .where('correo', isEqualTo: correoFinal)
            .limit(1)
            .get();

        if (consulta.docs.isEmpty) {
          _mostrarDialogo("Error", "No se encontró información del usuario.");
          return;
        }

        final datosUsuario = consulta.docs.first.data();
        final rol = datosUsuario['rol'];

        if (rol == 'usuario') {
          Navigator.pushReplacementNamed(context, 'user_home');
        } else if (rol == 'administrador') {
          Navigator.pushReplacementNamed(context, 'admin_home');
        } else {
          _mostrarDialogo("Error", "Rol no reconocido: $rol");
        }
      } catch (e) {
        _mostrarDialogo("Error", "Correo o contraseña incorrectos.");
      } finally {
        setState(() {
          _cargaDeDatos = false;
        });
      }
    }
  }

  void _mostrarDialogo(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const azulGrisClaro = Color.fromARGB(255, 175, 183, 197);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/book.png', height: 100),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Registro Anecdótico',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: azulGrisClaro,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: correo,
                            decoration: const InputDecoration(
                              labelText: "Correo electrónico",
                              border: OutlineInputBorder(),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.isEmpty) {
                                return 'Ingresa tu correo';
                              }
                              final regex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              return regex.hasMatch(valor)
                                  ? null
                                  : 'Correo no válido';
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: contrasenia,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Contraseña",
                              border: OutlineInputBorder(),
                            ),
                            validator: (valor) {
                              if (valor == null || valor.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          _cargaDeDatos
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: iniciarSesion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: azulGrisClaro,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("Ingresar"),
                                ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, 'register');
                            },
                            child: Text(
                              "¿No tienes cuenta? Regístrate aquí",
                              style: TextStyle(color: azulGrisClaro),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
