import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/src/pages/widgets/registros_bottom_sheet.dart'; // Ajusta la ruta según tu proyecto
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';

class RecordsSummaryScreen extends StatefulWidget {
  const RecordsSummaryScreen({Key? key}) : super(key: key);

  @override
  State<RecordsSummaryScreen> createState() => _RecordsSummaryScreenState();
}

class _RecordsSummaryScreenState extends State<RecordsSummaryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool estaCargando = true;

  // Datos organizados: grado -> sección -> lista de alumnos
  Map<String, Map<String, List<Map<String, dynamic>>>> datos = {};

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() {
      estaCargando = true;
    });

    try {
      final registrosSnapshot = await _firestore.collection('records').get();

      Map<String, List<Map<String, dynamic>>> registrosPorAlumno = {};

      for (var regDoc in registrosSnapshot.docs) {
        final regData = regDoc.data();
        final studentId = regData['studentId'];
        if (studentId == null) continue;

        registrosPorAlumno.putIfAbsent(studentId, () => []);
        registrosPorAlumno[studentId]!.add(regData);
      }

      final alumnosSnapshot = await _firestore.collection('students').get();

      List<Map<String, dynamic>> alumnosConRegistros = [];

      for (var alumnoDoc in alumnosSnapshot.docs) {
        final alumnoData = alumnoDoc.data();
        final alumnoId = alumnoDoc.id;

        final nivelRaw = alumnoData['nivel'] ?? '';
        final nivel = nivelRaw.toString().toLowerCase().trim();

        if (nivel != 'nivel medio' && nivel != 'escolar basica') {
          continue; // filtro niveles
        }

        final gradoRaw = alumnoData['grado'] ?? 'sin grado';
        final grado = gradoRaw.toString().toLowerCase().trim();

        final seccionRaw = alumnoData['seccion'] ?? 'sin sección';
        final seccion = seccionRaw.toString().toLowerCase().trim();

        final listaRegistros = registrosPorAlumno[alumnoId] ?? [];

        final alumnoCompleto = Map<String, dynamic>.from(alumnoData);
        alumnoCompleto['docId'] = alumnoId;
        alumnoCompleto['registros'] = listaRegistros;
        alumnoCompleto['cantidadRegistros'] = listaRegistros.length;
        alumnoCompleto['nivel'] = nivel;
        alumnoCompleto['grado'] = grado;
        alumnoCompleto['seccion'] = seccion;

        alumnosConRegistros.add(alumnoCompleto);
      }

      // Organizar por grado y sección
      Map<String, Map<String, List<Map<String, dynamic>>>> datosTemp = {};

      for (var alumno in alumnosConRegistros) {
        final grado = alumno['grado'] ?? 'sin grado';
        final seccion = alumno['seccion'] ?? 'sin sección';

        datosTemp.putIfAbsent(grado, () => {});
        datosTemp[grado]!.putIfAbsent(seccion, () => []);
        datosTemp[grado]![seccion]!.add(alumno);
      }

      // Ordenar alumnos por número_lista
      for (var grado in datosTemp.keys) {
        for (var seccion in datosTemp[grado]!.keys) {
          datosTemp[grado]![seccion]!.sort(
            (a, b) => (a['numero_lista'] as int? ?? 9999).compareTo(
              b['numero_lista'] as int? ?? 9999,
            ),
          );
        }
      }

      setState(() {
        datos = datosTemp;
        estaCargando = false;
      });
    } catch (e) {
      setState(() {
        datos = {};
        estaCargando = false;
      });
      print('Error cargando datos: $e');
    }
  }

  void mostrarRegistros(Map<String, dynamic> alumno) {
    final listaRegistros = alumno['registros'] as List<dynamic>? ?? [];
    final nombreCompleto = '${alumno['nombre']} ${alumno['apellido']}';

    mostrarRegistrosBottomSheet(context, listaRegistros, nombreCompleto);
  }

  @override
  Widget build(BuildContext context) {
    const cremita = Color.fromARGB(248, 252, 230, 230);
    const rojoOscuro = Color.fromARGB(255, 39, 2, 2);

    // Orden personalizado para grados
    final ordenEscolarBasica = ['7', '8', '9'];
    final ordenNivelMedio = ['1', '2', '3'];

    // Extraer grados que hay en datos para cada nivel
    List<String> gradosEscolarBasica = datos.keys
        .where((g) => ordenEscolarBasica.any((o) => g.contains(o)))
        .toList();
    List<String> gradosNivelMedio = datos.keys
        .where((g) => ordenNivelMedio.any((o) => g.contains(o)))
        .toList();

    // Ordenarlos según la lista fija
    gradosEscolarBasica.sort((a, b) {
      int ia = ordenEscolarBasica.indexWhere((o) => a.contains(o));
      int ib = ordenEscolarBasica.indexWhere((o) => b.contains(o));
      return ia.compareTo(ib);
    });
    gradosNivelMedio.sort((a, b) {
      int ia = ordenNivelMedio.indexWhere((o) => a.contains(o));
      int ib = ordenNivelMedio.indexWhere((o) => b.contains(o));
      return ia.compareTo(ib);
    });

    if (estaCargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (datos.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No hay alumnos con registros.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cremita,
        iconTheme: const IconThemeData(color: rojoOscuro),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminUserHomeScreen(),
              ),
            );
          },
        ),
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
      body: ListView(
        children: [
          // Texto fijo para Escolar Básica
          Container(
            color: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: const Text(
              'Escolar Básica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Grados Escolar Básica con secciones y alumnos
          ...gradosEscolarBasica.map((grado) {
            final secciones = datos[grado]!;
            return ExpansionTile(
              title: Text(
                '$grado° Grado',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: secciones.entries.map((seccionEntry) {
                final seccion = seccionEntry.key;
                final alumnos = seccionEntry.value;

                return ExpansionTile(
                  title: Text(
                    'Sección: ${seccion[0].toUpperCase()}${seccion.substring(1)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: alumnos.map((alumno) {
                    return ListTile(
                      leading: SizedBox(
                        width: 30,
                        child: Center(
                          child: Text(
                            alumno['numero_lista']?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      title: GestureDetector(
                        onTap: alumno['cantidadRegistros'] > 0
                            ? () => mostrarRegistros(alumno)
                            : null,
                        child: Text(
                          '${alumno['nombre']} ${alumno['apellido']}',
                          style: TextStyle(
                            decoration: alumno['cantidadRegistros'] > 0
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            color: alumno['cantidadRegistros'] > 0
                                ? Colors.blue
                                : Colors.black87,
                          ),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: alumno['cantidadRegistros'] > 0
                              ? Colors.blue.shade100
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${alumno['cantidadRegistros']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: alumno['cantidadRegistros'] > 0
                                ? Colors.blue.shade800
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            );
          }),

          // Texto fijo para Nivel Medio
          Container(
            color: Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: const Text(
              'Nivel Medio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Grados Nivel Medio con secciones y alumnos
          ...gradosNivelMedio.map((grado) {
            final secciones = datos[grado]!;
            return ExpansionTile(
              title: Text(
                '$grado° Curso',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: secciones.entries.map((seccionEntry) {
                final seccion = seccionEntry.key;
                final alumnos = seccionEntry.value;

                return ExpansionTile(
                  title: Text(
                    'Sección: ${seccion[0].toUpperCase()}${seccion.substring(1)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: alumnos.map((alumno) {
                    return ListTile(
                      leading: SizedBox(
                        width: 30,
                        child: Center(
                          child: Text(
                            alumno['numero_lista']?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      title: GestureDetector(
                        onTap: alumno['cantidadRegistros'] > 0
                            ? () => mostrarRegistros(alumno)
                            : null,
                        child: Text(
                          '${alumno['nombre']} ${alumno['apellido']}',
                          style: TextStyle(
                            decoration: alumno['cantidadRegistros'] > 0
                                ? TextDecoration.underline
                                : TextDecoration.none,
                            color: alumno['cantidadRegistros'] > 0
                                ? Colors.blue
                                : Colors.black87,
                          ),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: alumno['cantidadRegistros'] > 0
                              ? Colors.blue.shade100
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${alumno['cantidadRegistros']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: alumno['cantidadRegistros'] > 0
                                ? Colors.blue.shade800
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
