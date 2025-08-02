import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EscolarBasicaScreen extends StatefulWidget {
  const EscolarBasicaScreen({super.key});

  @override
  State<EscolarBasicaScreen> createState() => _EscolarBasicaScreenState();
}

class _EscolarBasicaScreenState extends State<EscolarBasicaScreen> {
  bool estaCargando = true;

  // Estructura para guardar los datos organizados
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

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('nivel', isEqualTo: 'escolar basica')
        .get();

    final datosTemp = <String, Map<String, List<Map<String, dynamic>>>>{};

    for (var doc in snapshot.docs) {
      final d = doc.data();
      final grado = d['grado'] ?? 'Sin grado';
      final seccion = d['seccion'] ?? 'Sin sección';

      datosTemp.putIfAbsent(grado, () => {});
      datosTemp[grado]!.putIfAbsent(seccion, () => []);

      Map<String, dynamic> alumnoConId = Map<String, dynamic>.from(d);
      alumnoConId['docId'] = doc.id;

      datosTemp[grado]![seccion]!.add(alumnoConId);
    }

    // Ordenar grados y secciones
    final gradosOrdenados = datosTemp.keys.toList()..sort();
    final datosOrdenados = <String, Map<String, List<Map<String, dynamic>>>>{};

    for (var grado in gradosOrdenados) {
      final secciones = datosTemp[grado]!;
      final seccionesOrdenadas = secciones.keys.toList()..sort();

      final seccionesOrdenadasMap = <String, List<Map<String, dynamic>>>{};
      for (var sec in seccionesOrdenadas) {
        final alumnos = secciones[sec]!;

        alumnos.sort(
          (a, b) =>
              (a['numero_lista'] as int).compareTo(b['numero_lista'] as int),
        );

        seccionesOrdenadasMap[sec] = alumnos;
      }
      datosOrdenados[grado] = seccionesOrdenadasMap;
    }

    setState(() {
      datos = datosOrdenados;
      estaCargando = false;
    });
  }

  // Guardar registro de conducta con descripción y comentario
  Future<void> registrarConducta({
    required String color,
    required String comentario,
    required String descripcion,
    required Map<String, dynamic> alumno,
  }) async {
    final registro = {
      'studentId': alumno['docId'],
      'fecha': DateTime.now(),
      'color': color,
      'descripcion': descripcion,
      'comentario': comentario,
      'grado': alumno['grado'],
      'seccion': alumno['seccion'],
      'nivel': alumno['nivel'],
      'nombreUsuario': 'Cargo Nombre Apellido', // Ajustar usuario real
    };

    await FirebaseFirestore.instance.collection('records').add(registro);
  }

  Future<void> mostrarDialogoRegistro(
    Map<String, dynamic> alumno,
    String color,
  ) async {
    final _formKey = GlobalKey<FormState>();
    String descripcion = '';
    String comentario = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Registrar conducta - ${color[0].toUpperCase()}${color.substring(1)}',
          ),
          content: SizedBox(
            width: 350,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción del suceso',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descripción es obligatoria';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      descripcion = value!.trim();
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Comentario',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El comentario es obligatorio';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      comentario = value!.trim();
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  await registrarConducta(
                    color: color,
                    comentario: comentario,
                    descripcion: descripcion,
                    alumno: alumno,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Registro guardado para ${alumno['nombre']}',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Color colorDeCadena(String color) {
    switch (color.toLowerCase()) {
      case 'rojo':
        return Colors.red;
      case 'amarillo':
        return Colors.amber;
      case 'verde':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (estaCargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Escolar Básica')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: datos.entries.map((gradoEntry) {
          final grado = gradoEntry.key;
          final secciones = gradoEntry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grado: $grado',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...secciones.entries.map((seccionEntry) {
                final seccion = seccionEntry.key;
                final alumnos = seccionEntry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sección: ${seccion[0].toUpperCase()}${seccion.substring(1)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
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
                            flex: 4,
                            child: Text(
                              'Nombre y Apellido',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Evaluación',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...alumnos.map((alumno) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text('${alumno['numero_lista']}'),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                '${alumno['nombre']} ${alumno['apellido']}',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.circle,
                                      color: Colors.green,
                                    ),
                                    onPressed: () =>
                                        mostrarDialogoRegistro(alumno, 'verde'),
                                    tooltip: 'Marcar conducta verde',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.circle,
                                      color: Colors.amber,
                                    ),
                                    onPressed: () => mostrarDialogoRegistro(
                                      alumno,
                                      'amarillo',
                                    ),
                                    tooltip: 'Marcar conducta amarillo',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.circle, color: Colors.red),
                                    onPressed: () =>
                                        mostrarDialogoRegistro(alumno, 'rojo'),
                                    tooltip: 'Marcar conducta rojo',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                  ],
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}
