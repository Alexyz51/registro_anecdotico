import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/src/pages/widgets/breadcrumb_navigation.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/common_user/common_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/lista_de_alumnos_escolar_basica_screen.dart';

class EscolarBasicaScreen extends StatefulWidget {
  const EscolarBasicaScreen({super.key});

  @override
  State<EscolarBasicaScreen> createState() => _EscolarBasicaScreenState();
}

class _EscolarBasicaScreenState extends State<EscolarBasicaScreen> {
  Map<String, String> usuarioActual = {
    'nombre': '',
    'apellido': '',
    'rol': '',
    'rolReal': '',
  };

  final List<String> grados = const [
    "Séptimo grado",
    "Octavo grado",
    "Noveno grado",
  ];

  @override
  void initState() {
    super.initState();
    obtenerUsuarioActual();
  }

  Future<void> obtenerUsuarioActual() async {
    final User? usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(usuario.uid)
        .get();
    if (!doc.exists) return;

    final data = doc.data()!;
    setState(() {
      usuarioActual['nombre'] = data['nombre'] ?? '';
      usuarioActual['apellido'] = data['apellido'] ?? '';
      usuarioActual['rol'] = data['rol'] ?? '';
      usuarioActual['rolReal'] = data['rolReal'] ?? '';
    });
  }

  void _onGradoPressed(String seccion, String grado) {
    // Redirige a la pantalla de lista de alumnos con grado y sección
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ListaAlumnosEscolarBasicaScreen(grado: grado, seccion: seccion),
      ),
    );
  }

  Widget _buildSeccion(String seccion) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "🔹 Sección $seccion",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...grados.map((grado) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ElevatedButton(
              onPressed: () => _onGradoPressed(seccion, grado),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(grado),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escolar Básica"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: BreadcrumbBar(
                items: [
                  BreadcrumbItem(
                    recorrido: 'Inicio',
                    onTap: () {
                      if (usuarioActual['rolReal'] == 'administrador') {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminUserHomeScreen(),
                          ),
                          (route) => false,
                        );
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommonUserHomeScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                  BreadcrumbItem(recorrido: 'Grados por Sección'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Grados por Sección",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildSeccion("A"),
            _buildSeccion("B"),
          ],
        ),
      ),
    );
  }
}
