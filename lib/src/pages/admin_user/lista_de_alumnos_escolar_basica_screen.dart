import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/src/pages/widgets/breadcrumb_navigation.dart';

class ListaAlumnosEscolarBasicaScreen extends StatelessWidget {
  final String grado; // "Séptimo grado", "Octavo grado", "Noveno grado"
  final String seccion; // "a" o "b"

  const ListaAlumnosEscolarBasicaScreen({
    super.key,
    required this.grado,
    required this.seccion,
  });

  // Convertimos el grado en número para que coincida con Firestore
  int get gradoNum {
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

  // Consulta a Firestore filtrada
  Stream<QuerySnapshot> obtenerAlumnos() {
    return FirebaseFirestore.instance
        .collection('alumnos')
        .where('grado', isEqualTo: gradoNum)
        .where(
          'seccion',
          isEqualTo: seccion.toLowerCase(),
        ) // Sección en minúscula
        .orderBy('numero_lista')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$grado - Sección ${seccion.toUpperCase()}'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: BreadcrumbBar(
              items: [
                BreadcrumbItem(
                  recorrido: 'Inicio',
                  onTap: () => Navigator.pop(context),
                ),
                BreadcrumbItem(recorrido: 'Lista de Alumnos'),
              ],
            ),
          ),
          // Encabezado tipo Excel
          Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: const [
                Expanded(
                  flex: 1,
                  child: Text(
                    'N°',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nombre',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Apellido',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Lista de alumnos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: obtenerAlumnos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hay alumnos en esta sección'),
                  );
                }

                final alumnos = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: alumnos.length,
                  itemBuilder: (context, index) {
                    final alumno =
                        alumnos[index].data() as Map<String, dynamic>;
                    final color = index % 2 == 0
                        ? Colors.grey[100]
                        : Colors.white;

                    return Container(
                      color: color,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(alumno['numero_lista'].toString()),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(alumno['nombre'] ?? ''),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(alumno['apellido'] ?? ''),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
