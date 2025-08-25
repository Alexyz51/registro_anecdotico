/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/common_user/common_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/escolar_basica.dart';
import 'package:registro_anecdotico/src/pages/admin_user/registrar_conducta_screen.dart'; // <-- Nueva pantalla

class ListaAlumnosEscolarBasicaScreen extends StatefulWidget {
  final int grado;
  final String seccion;

  const ListaAlumnosEscolarBasicaScreen({
    super.key,
    required this.grado,
    required this.seccion,
  });

  @override
  State<ListaAlumnosEscolarBasicaScreen> createState() =>
      _ListaAlumnosEscolarBasicaScreenState();
}

class _ListaAlumnosEscolarBasicaScreenState
    extends State<ListaAlumnosEscolarBasicaScreen> {
  bool estaCargando = true;
  List<Map<String, dynamic>> alumnosFiltrados = [];
  Map<String, String> usuarioActual = {
    'rol': '',
    'rolReal': '',
    'nombre': '',
    'apellido': '',
  };

  @override
  void initState() {
    super.initState();
    cargarUsuarioActual();
    cargarAlumnos();
  }

  Future<void> cargarUsuarioActual() async {
    User? usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(usuario.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        usuarioActual['rol'] = data['rol'] ?? '';
        usuarioActual['rolReal'] = data['rolReal'] ?? '';
        usuarioActual['nombre'] = data['nombre'] ?? '';
        usuarioActual['apellido'] = data['apellido'] ?? '';
      });
    }
  }

  Future<void> cargarAlumnos() async {
    setState(() {
      estaCargando = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .get();

    final listaTemp = <Map<String, dynamic>>[];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final seccionDb = (data['seccion'] ?? '').toString().toLowerCase().trim();
      final gradoDb =
          int.tryParse(
            (data['grado'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;

      if (seccionDb == widget.seccion.toLowerCase() &&
          gradoDb == widget.grado) {
        final alumnoConId = Map<String, dynamic>.from(data);
        alumnoConId['docId'] = doc.id;
        listaTemp.add(alumnoConId);
      }
    }

    listaTemp.sort(
      (a, b) => (a['numero_lista'] as int).compareTo(b['numero_lista'] as int),
    );

    setState(() {
      alumnosFiltrados = listaTemp;
      estaCargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color cremita = Color.fromARGB(248, 252, 230, 230);
    const rojoOscuro = Color.fromARGB(255, 39, 2, 2);

    if (estaCargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: rojoOscuro, height: 5.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texto de grado y sección
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${widget.grado}° Grado - Sección ${widget.seccion.toUpperCase()}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Encabezado de la lista
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: const [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      'N°',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Línea vertical de separación
                VerticalDivider(color: Colors.grey, thickness: 1),
                Expanded(
                  flex: 6,
                  child: Text(
                    'Nombre y Apellido',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Lista de alumnos con separación vertical
          Expanded(
            child: ListView.builder(
              itemCount: alumnosFiltrados.length,
              itemBuilder: (context, index) {
                final alumno = alumnosFiltrados[index];
                final color = index % 2 == 0 ? Colors.grey[100] : Colors.white;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegistrarConductaScreen(alumno: alumno),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(alumno['numero_lista'].toString()),
                          ),
                        ),
                        // Línea vertical de separación
                        Container(width: 1, height: 20, color: Colors.grey),
                        Expanded(
                          flex: 6,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              '${alumno['nombre'] ?? ''} ${alumno['apellido'] ?? ''}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/
