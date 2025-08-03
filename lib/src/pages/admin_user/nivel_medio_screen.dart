import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NivelMedioScreen extends StatefulWidget {
  const NivelMedioScreen({super.key});

  @override
  State<NivelMedioScreen> createState() => _NivelMedioScreenState();
}

class _NivelMedioScreenState extends State<NivelMedioScreen> {
  bool estaCargando = true;
  Map<String, Map<String, List<Map<String, dynamic>>>> datos = {};
  Map<String, String> usuarioActual = {
    'cargo': '',
    'nombre': '',
    'apellido': '',
  };

  @override
  void initState() {
    super.initState();
    cargarDatos();
    cargarUsuarioActual();
  }

  Future<void> cargarDatos() async {
    setState(() {
      estaCargando = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('nivel', isEqualTo: 'nivel medio')
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

  Future<void> cargarUsuarioActual() async {
    String uidActual = 'uid_usuario_autenticado';

    final docUser = await FirebaseFirestore.instance
        .collection('users')
        .doc(uidActual)
        .get();

    if (docUser.exists) {
      final data = docUser.data()!;
      setState(() {
        usuarioActual['cargo'] = data['cargo'] ?? '';
        usuarioActual['nombre'] = data['nombre'] ?? '';
        usuarioActual['apellido'] = data['apellido'] ?? '';
      });
    }
  }

  Future<void> registrarConducta({
    required String color,
    required String descripcion,
    required String comentario,
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
      'registrado_por':
          '${usuarioActual['cargo']} ${usuarioActual['nombre']} ${usuarioActual['apellido']}',
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
          content: Form(
            key: _formKey,
            child: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      maxLines: 2,
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
                    const SizedBox(height: 12),
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
                    descripcion: descripcion,
                    comentario: comentario,
                    alumno: alumno,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Registro guardado de ${alumno['nombre']}'),
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

  @override
  Widget build(BuildContext context) {
    if (estaCargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Escolar Básica')),
      body: ListView(
        children: datos.entries.map((gradoEntry) {
          final grado = gradoEntry.key;
          final secciones = gradoEntry.value;

          return ExpansionTile(
            title: Text('$grado° Curso'),
            children: secciones.entries.map((seccionEntry) {
              final seccion = seccionEntry.key;
              final alumnos = seccionEntry.value;

              return ExpansionTile(
                title: Text(
                  'Sección: ${seccion[0].toUpperCase()}${seccion.substring(1)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  // ENCABEZADO
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 30,
                              child: Center(
                                child: Text(
                                  'Nro',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 180,
                              child: Text(
                                'Nombre y Apellido',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 160,
                              child: Center(
                                child: Text(
                                  'Evaluación',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // FILAS DE ALUMNOS
                  ...alumnos.map((alumno) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade400,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: Center(
                                    child: Text(
                                      alumno['numero_lista'].toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: Colors.grey.shade400,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    '${alumno['nombre']} ${alumno['apellido']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: Colors.grey.shade400,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.circle,
                                          color: Colors.green,
                                          size: 24,
                                        ),
                                        onPressed: () => mostrarDialogoRegistro(
                                          alumno,
                                          'verde',
                                        ),
                                        tooltip: 'Marcar conducta verde',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.circle,
                                          color: Colors.amber,
                                          size: 24,
                                        ),
                                        onPressed: () => mostrarDialogoRegistro(
                                          alumno,
                                          'amarillo',
                                        ),
                                        tooltip: 'Marcar conducta amarillo',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.circle,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                        onPressed: () => mostrarDialogoRegistro(
                                          alumno,
                                          'rojo',
                                        ),
                                        tooltip: 'Marcar conducta rojo',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
