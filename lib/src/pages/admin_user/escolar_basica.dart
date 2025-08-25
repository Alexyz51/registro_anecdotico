/*import 'package:flutter/material.dart';
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

  int gradoNum(String grado) {
    switch (grado) {
      case "Séptimo grado":
        return 7;
      case "Octavo grado":
        return 8;
      case "Noveno grado":
        return 9;
      default:
        return 0;
    }
  }

  void _onGradoPressed(String seccion, String grado) {
    int numeroGrado = gradoNum(grado);
    String seccionLower = seccion.toLowerCase();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaAlumnosEscolarBasicaScreen(
          grado: numeroGrado,
          seccion: seccionLower,
        ),
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
    const Color cremita = Color.fromARGB(248, 252, 230, 230);
    const rojoOscuro = Color.fromARGB(255, 39, 2, 2);

    return Scaffold(
      backgroundColor: cremita,
      appBar: AppBar(
        backgroundColor: cremita,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (usuarioActual['rol'] == 'administrador') {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AdminUserHomeScreen()),
                (route) => false,
              );
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => CommonUserHomeScreen()),
                (route) => false,
              );
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Registro Anecdotico',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(226, 201, 183, 171),
          ),
        ),
        automaticallyImplyLeading: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: rojoOscuro, height: 5.0),
        ),
      ),
      body: SingleChildScrollView(
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
                  BreadcrumbItem(recorrido: 'Secciones'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Secciones",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildSeccion("A"),
                  _buildSeccion("B"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
