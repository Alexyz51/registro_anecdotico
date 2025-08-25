import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  String nombre = '';
  String apellido = '';
  String cargo = '';
  String rolApp = '';

  bool estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          nombre = data['nombre'] ?? '';
          apellido = data['apellido'] ?? '';
          cargo = data['rolReal'] ?? '';
          final rol = data['rol'] ?? '';
          rolApp = rol.isNotEmpty
              ? rol[0].toUpperCase() + rol.substring(1)
              : rol;
          estaCargando = false;
        });
      }
    }
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  Future<void> _eliminarCuenta() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      // Primero eliminar documentos relacionados si es necesario
      await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .delete();
      await usuario.delete();
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    const miColor = Color(0xFF8e0b13);

    if (estaCargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información del usuario
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            tileColor: miColor,
            title: Text(
              '$nombre $apellido',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '$cargo - $rolApp',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 20),

          // Opciones de configuración
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar sesión'),
              onTap: _cerrarSesion,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Eliminar cuenta'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Confirmar eliminación'),
                    content: const Text(
                      '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _eliminarCuenta();
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('Acerca de la aplicación'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Registro Anecdótico',
                  applicationVersion: '1.0.0',
                  children: const [
                    Text(
                      'Esta aplicación permite gestionar registros de conducta de estudiantes.',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
