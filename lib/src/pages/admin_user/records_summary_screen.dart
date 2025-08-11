import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/src/pages/widgets/registros_bottom_sheet.dart'; // Ajusta la ruta según tu proyecto
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
              alumnoCompleto['seccion']?.toString() ?? 'Sin sección';

          alumnosConRegistros.add(alumnoCompleto);
        }
      }

      Map<String, Map<String, List<Map<String, dynamic>>>> datosTemp = {};

      for (var alumno in alumnosConRegistros) {
        final grado = alumno['grado'] ?? 'sin grado';
        final seccion = alumno['seccion'] ?? 'sin sección';

        datosTemp.putIfAbsent(grado, () => {});
        datosTemp[grado]!.putIfAbsent(seccion, () => []);
        datosTemp[grado]![seccion]!.add(alumno);
      }

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
    const Color cremitaGris = Color(0xFFC7B7A3);
    final grisClarito = Colors.grey.shade200;
    final grisMedio = Colors.grey.shade300;
    final rojoClaro = Colors.red.shade100;
    String hexColor = '#8e0b13';
    int colorValue = int.parse(hexColor.substring(1), radix: 16);
    Color miColor = Color(colorValue | 0xFF000000);
    const cremita = const Color.fromARGB(248, 252, 230, 230);
    const rojoOscuro = Color.fromARGB(255, 39, 2, 2);
    //Paleta de colores habitual

    // Orden personalizado para grados
    final ordenEscolarBasica = ['7', '8', '9'];
    final ordenNivelMedio = ['1', '2', '3'];

    List<String> gradosEscolarBasica = datos.keys
        .where((g) => ordenEscolarBasica.any((o) => g.contains(o)))
        .toList();
    List<String> gradosNivelMedio = datos.keys
        .where((g) => ordenNivelMedio.any((o) => g.contains(o)))
        .toList();

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
      backgroundColor: cremita,
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
          // Breadcrumb con fondo gris clarito y padding
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: BreadcrumbBar(
              items: [
                BreadcrumbItem(
                  recorrido: 'Secciones',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'admin_home');
                  },
                  textoColor: rojoOscuro,
                ),
                BreadcrumbItem(recorrido: 'Reportes', textoColor: rojoOscuro),
              ],
            ),
          ),

          const SizedBox(height: 0),

          // Título fijo Escolar Básica con fondo gris clarito y bordes arriba y abajo
          /*
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: grisClarito,
              border: Border(
                top: BorderSide(color: rojoOscuro.withOpacity(0.3), width: 1),
                bottom: BorderSide(
                  color: rojoOscuro.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
            child: const Text(
              'Escolar Básica',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: rojoOscuro,
                letterSpacing: 1.1,
              ),
            ),
          ),

          const SizedBox(height: 10),
          */
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              'Escolar Básica',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: rojoOscuro,
                //letterSpacing: 1.1,
              ),
            ),
          ),

          // Grados Escolar Básica con ExpansionTiles personalizados
          ...gradosEscolarBasica.map((grado) {
            final secciones = datos[grado]!;
            return ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              iconColor: rojoOscuro,
              collapsedIconColor: rojoOscuro.withOpacity(0.6),
              title: Text(
                '$grado° Grado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: rojoOscuro,
                ),
              ),
              children: secciones.entries.map((seccionEntry) {
                final seccion = seccionEntry.key;
                final alumnos = seccionEntry.value;

                return ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 4,
                  ),
                  iconColor: rojoOscuro,
                  collapsedIconColor: rojoOscuro.withOpacity(0.6),
                  title: Text(
                    'Sección: ${seccion[0].toUpperCase()}${seccion.substring(1)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: rojoOscuro,
                    ),
                  ),
                  children: alumnos.map((alumno) {
                    return ListTile(
                      leading: SizedBox(
                        width: 30,
                        child: Center(
                          child: Text(
                            alumno['numero_lista']?.toString() ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: rojoOscuro,
                            ),
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
                                ? Colors.red.shade700
                                : rojoOscuro,
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
                              ? rojoClaro
                              : grisMedio,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${alumno['cantidadRegistros']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: alumno['cantidadRegistros'] > 0
                                ? Colors.red.shade900
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

          const SizedBox(height: 12),

          // Título fijo Nivel Medio
          /*
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: grisClarito,
              border: Border(
                top: BorderSide(color: rojoOscuro.withOpacity(0.3), width: 1),
                bottom: BorderSide(
                  color: rojoOscuro.withOpacity(0.3),
                  width: 1,
                ),
             ),
            ),
            child: 
            const Text(
              'Nivel Medio',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: rojoOscuro,
                //letterSpacing: 1.1,
              ),
            ),
          ),

          const SizedBox(height: 0),
          */
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              'Nivel Medio',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: rojoOscuro,
                //letterSpacing: 1.1,
              ),
            ),
          ),

          // Grados Nivel Medio
          ...gradosNivelMedio.map((grado) {
            final secciones = datos[grado]!;
            return ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 2,
              ),
              iconColor: rojoOscuro,
              collapsedIconColor: rojoOscuro.withOpacity(0.6),
              title: Text(
                '$grado° Curso',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: rojoOscuro,
                ),
              ),

              children: /*[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          'N° Lista',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rojoOscuro,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Nombre y Apellido',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: rojoOscuro,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ...*/ secciones.entries.map((seccionEntry) {
                final seccion = seccionEntry.key;
                final alumnos = seccionEntry.value;

                return ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 4,
                  ),
                  iconColor: rojoOscuro,
                  collapsedIconColor: rojoOscuro.withOpacity(0.6),
                  title: Text(
                    'Sección: ${seccion[0].toUpperCase()}${seccion.substring(1)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: rojoOscuro,
                    ),
                  ),
                  children: alumnos.map((alumno) {
                    return ListTile(
                      leading: SizedBox(
                        width: 30,
                        child: Center(
                          child: Text(
                            alumno['numero_lista']?.toString() ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: rojoOscuro,
                            ),
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
                                ? Colors.red.shade700
                                : rojoOscuro,
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
                              ? rojoClaro
                              : grisMedio,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${alumno['cantidadRegistros']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: alumno['cantidadRegistros'] > 0
                                ? Colors.red.shade900
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
          const SizedBox(
            height: 20,
          ), // Espacio final para que no quede pegado abajo
        ],
      ),
    );
  }
}
