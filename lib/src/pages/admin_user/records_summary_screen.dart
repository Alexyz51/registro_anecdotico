import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/src/pages/widgets/registros_bottom_sheet.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';
import '../widgets/breadcrumb_navigation.dart';

class RecordsSummaryScreen extends StatefulWidget {
  const RecordsSummaryScreen({Key? key}) : super(key: key);

  @override
  State<RecordsSummaryScreen> createState() => _RecordsSummaryScreenState();
}

class _RecordsSummaryScreenState extends State<RecordsSummaryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool estaCargando = true;

  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>
  datosPorNivelGuardados = {};

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

        final nivel = (alumnoData['nivel'] ?? '').toString().toLowerCase();
        if (nivel != 'nivel medio' && nivel != 'escolar basica') {
          continue;
        }

        final listaRegistros = registrosPorAlumno[alumnoId] ?? [];

        if (listaRegistros.isNotEmpty) {
          final alumnoCompleto = Map<String, dynamic>.from(alumnoData);
          alumnoCompleto['docId'] = alumnoId;
          alumnoCompleto['registros'] = listaRegistros;
          alumnoCompleto['cantidadRegistros'] = listaRegistros.length;
          alumnoCompleto['nivel'] = nivel;
          alumnoCompleto['grado'] =
              alumnoCompleto['grado']?.toString() ?? 'Sin grado';
          alumnoCompleto['seccion'] =
              alumnoCompleto['seccion']?.toString().toLowerCase() ??
              'sin sección';

          alumnosConRegistros.add(alumnoCompleto);
        }
      }

      Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>
      datosPorNivel = {};

      for (var alumno in alumnosConRegistros) {
        final nivel = alumno['nivel'] ?? 'sin nivel';
        final seccion = alumno['seccion'] ?? 'sin seccion';
        final grado = alumno['grado'] ?? 'sin grado';

        datosPorNivel.putIfAbsent(nivel, () => {});
        datosPorNivel[nivel]!.putIfAbsent(seccion, () => {});
        datosPorNivel[nivel]![seccion]!.putIfAbsent(grado, () => []);
        datosPorNivel[nivel]![seccion]![grado]!.add(alumno);
      }

      datosPorNivel.forEach((nivel, secciones) {
        secciones.forEach((seccion, grados) {
          grados.forEach((grado, alumnos) {
            alumnos.sort(
              (a, b) => (a['numero_lista'] as int? ?? 9999).compareTo(
                b['numero_lista'] as int? ?? 9999,
              ),
            );
          });
        });
      });

      setState(() {
        datosPorNivelGuardados = datosPorNivel;
        estaCargando = false;
      });
    } catch (e) {
      setState(() {
        datosPorNivelGuardados = {};
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
    const Color cremita = Color.fromARGB(248, 252, 230, 230);
    final grisClaro = Colors.grey.shade300;
    final textoColor = Colors.black87;

    final ordenEscolarBasica = ['7', '8', '9'];
    final ordenNivelMedio = ['1', '2', '3'];
    final nivelesOrdenados = ['escolar basica', 'nivel medio'];

    if (estaCargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (datosPorNivelGuardados.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No hay alumnos con registros.')),
      );
    }

    return Scaffold(
      backgroundColor: cremita,
      appBar: AppBar(
        backgroundColor: cremita,
        iconTheme: const IconThemeData(),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, 'admin_home');
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
          preferredSize: const Size.fromHeight(2.0),
          child: Container(color: grisClaro, height: 2.0),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          BreadcrumbBar(
            items: [
              BreadcrumbItem(
                recorrido: 'Secciones',
                onTap: () {
                  Navigator.pushReplacementNamed(context, 'admin_home');
                },
                textoColor: textoColor,
              ),
              BreadcrumbItem(recorrido: 'Reportes', textoColor: textoColor),
            ],
          ),

          const SizedBox(height: 12),

          ...nivelesOrdenados.map((nivel) {
            final secciones = datosPorNivelGuardados[nivel] ?? {};

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 0,
                  ),
                  child: Text(
                    nivel == 'escolar basica'
                        ? 'Escolar Básica'
                        : 'Nivel Medio',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.normal,
                      color: textoColor,
                    ),
                  ),
                ),

                ...secciones.entries.map((seccionEntry) {
                  final seccion = seccionEntry.key;
                  final gradosMap = seccionEntry.value;

                  final gradosList = gradosMap.entries.toList();
                  gradosList.sort((a, b) {
                    List<String> ordenGrados = nivel == 'escolar basica'
                        ? ordenEscolarBasica
                        : ordenNivelMedio;

                    String gradoA = a.key.replaceAll(RegExp(r'[^0-9]'), '');
                    String gradoB = b.key.replaceAll(RegExp(r'[^0-9]'), '');

                    int ia = ordenGrados.indexOf(gradoA);
                    int ib = ordenGrados.indexOf(gradoB);
                    if (ia == -1) ia = 9999;
                    if (ib == -1) ib = 9999;
                    return ia.compareTo(ib);
                  });

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nivel == 'escolar basica'
                              ? 'Sección ${seccion[0].toUpperCase()}${seccion.substring(1)}'
                              : '${seccion[0].toUpperCase()}${seccion.substring(1)}',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 18,
                            color: textoColor,
                          ),
                        ),

                        const SizedBox(height: 6),

                        ...gradosList.map((gradoEntry) {
                          final grado = gradoEntry.key;
                          final alumnos = gradoEntry.value;

                          return ExpansionTile(
                            key: PageStorageKey('$nivel-$seccion-$grado'),
                            tilePadding: EdgeInsets.zero,
                            childrenPadding: EdgeInsets.zero,
                            iconColor: textoColor,
                            collapsedIconColor: textoColor.withOpacity(0.6),
                            title: Text(
                              nivel == 'escolar basica'
                                  ? '$grado° Grado'
                                  : '$grado° Curso',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: textoColor,
                              ),
                            ),
                            children: [
                              // Encabezado sin padding ni margen
                              Container(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      child: Center(
                                        child: Text(
                                          'Nro',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: textoColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    // Aquí el espacio que separe (pon 8 o menos para reducir margen)
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Nombre y Apellido',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: textoColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Lista de alumnos, sin padding horizontal
                              ...alumnos.map((alumno) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: grisClaro,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 0,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Center(
                                          child: Text(
                                            alumno['numero_lista'].toString(),
                                            style: TextStyle(
                                              color: textoColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1.0,
                                        height: 22,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        color: grisClaro,
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: alumno['cantidadRegistros'] > 0
                                              ? () => mostrarRegistros(alumno)
                                              : null,
                                          child: Text(
                                            '${alumno['nombre']} ${alumno['apellido']}',
                                            style: TextStyle(
                                              color: textoColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                              decoration: TextDecoration.none,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: alumno['cantidadRegistros'] > 0
                                              ? Colors.red.shade100
                                              : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${alumno['cantidadRegistros']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                alumno['cantidadRegistros'] > 0
                                                ? Colors.red.shade900
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          );

                          /*return ExpansionTile(
                            key: PageStorageKey('$nivel-$seccion-$grado'),
                            tilePadding: EdgeInsets.zero,
                            childrenPadding:
                                EdgeInsets.zero, // Sin margen en los hijos
                            /*const EdgeInsets.symmetric(
                              horizontal: 0,
                            ),*/
                            iconColor: textoColor,
                            collapsedIconColor: textoColor.withOpacity(0.6),
                            title: Text(
                              nivel == 'escolar basica'
                                  ? '$grado° Grado'
                                  : '$grado° Curso',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                color: textoColor,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      child: Center(
                                        child: Text(
                                          'Nro',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: textoColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: Text(
                                        'Nombre y Apellido',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: textoColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              ...alumnos.map((alumno) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: grisClaro,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Center(
                                          child: Text(
                                            alumno['numero_lista'].toString(),
                                            style: TextStyle(
                                              color: textoColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 1.5,
                                        height: 22,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        color: grisClaro,
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: alumno['cantidadRegistros'] > 0
                                              ? () => mostrarRegistros(alumno)
                                              : null,
                                          child: Text(
                                            '${alumno['nombre']} ${alumno['apellido']}',
                                            style: TextStyle(
                                              color: textoColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 14,
                                              decoration: TextDecoration.none,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: alumno['cantidadRegistros'] > 0
                                              ? Colors.red.shade100
                                              : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${alumno['cantidadRegistros']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                alumno['cantidadRegistros'] > 0
                                                ? Colors.red.shade900
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          );*/
                        }),
                      ],
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
