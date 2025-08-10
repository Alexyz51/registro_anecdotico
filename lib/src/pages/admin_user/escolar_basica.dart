import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EscolarBasicaScreen extends StatefulWidget {
  const EscolarBasicaScreen({super.key});

  @override
  State<EscolarBasicaScreen> createState() => _EscolarBasicaScreenState();
}

class _EscolarBasicaScreenState extends State<EscolarBasicaScreen> {
  bool estaCargando = true;
  Map<String, Map<String, List<Map<String, dynamic>>>> datos = {};
  Map<String, String> usuarioActual = {
    'rolReal': '',
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

  Future<void> cargarUsuarioActual() async {
    User? usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return;
    }

    String uidActual = usuario.uid;

    final docUser = await FirebaseFirestore.instance
        .collection('users')
        .doc(uidActual)
        .get();

    if (docUser.exists) {
      final data = docUser.data()!;
      setState(() {
        usuarioActual['rolReal'] = data['rolReal'] ?? '';
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
          '${usuarioActual['rolReal']} ${usuarioActual['nombre']} ${usuarioActual['apellido']}',
    };

    await FirebaseFirestore.instance.collection('records').add(registro);
  }

  Future<void> mostrarDialogoClasificacion(Map<String, dynamic> alumno) async {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController comentarioController = TextEditingController();
    final TextEditingController otrosController = TextEditingController();

    final List<String> conductasFrecuentes = [
      'No entrega tarea',
      'No mantiene una conducta apropiada',
      'Ausencia justificada',
      'Ausencia injustificada',
      'Llegada tardía',
      'No usa el uniforme correspondiente',
      'Trae objetos distractores en la institución',
      'Ausente con reposo médico',
    ];

    await showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // VARIABLES DE ESTADO MOVIDAS AQUÍ
            String? colorSeleccionado;
            Map<String, bool> conductasSeleccionadas = {
              for (var c in conductasFrecuentes) c: false,
            };
            bool otrosSeleccionado = false;

            return AlertDialog(
              title: const Text(
                'Registrar conducta',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              content: Container(
                width: dialogWidth,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Clasificación',
                              style: TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  colorSeleccionado = 'verde';
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.green,
                                radius: 9,
                                child: colorSeleccionado == 'verde'
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  colorSeleccionado = 'amarillo';
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.amber,
                                radius: 9,
                                child: colorSeleccionado == 'amarillo'
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  colorSeleccionado = 'rojo';
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.red,
                                radius: 9,
                                child: colorSeleccionado == 'rojo'
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Conductas frecuentes:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...conductasFrecuentes.map((conducta) {
                          return CheckboxListTile(
                            title: Text(conducta),
                            value: conductasSeleccionadas[conducta],
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (bool? value) {
                              setStateDialog(() {
                                conductasSeleccionadas[conducta] =
                                    value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          );
                        }).toList(),
                        CheckboxListTile(
                          title: const Text('Otros'),
                          value: otrosSeleccionado,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (bool? value) {
                            setStateDialog(() {
                              otrosSeleccionado = value ?? false;
                              if (!otrosSeleccionado) {
                                otrosController.clear();
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (otrosSeleccionado)
                          TextFormField(
                            controller: otrosController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              labelText: 'Describa la conducta personalizada',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (otrosSeleccionado &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Debe describir la conducta personalizada';
                              }
                              return null;
                            },
                          ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: comentarioController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Sugerencias / Reflexión',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Debe ingresar una sugerencia o reflexión (puede ser un guion)';
                            }
                            return null;
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
                    if (!_formKey.currentState!.validate()) return;

                    if (colorSeleccionado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Debe seleccionar un color'),
                        ),
                      );
                      return;
                    }

                    List<String> conductasSeleccionadasLista =
                        conductasSeleccionadas.entries
                            .where((e) => e.value)
                            .map((e) => e.key)
                            .toList();

                    if (otrosSeleccionado &&
                        otrosController.text.trim().isNotEmpty) {
                      conductasSeleccionadasLista.add(
                        otrosController.text.trim(),
                      );
                    }

                    if (conductasSeleccionadasLista.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Debe seleccionar al menos una conducta o escribir en Otros',
                          ),
                        ),
                      );
                      return;
                    }

                    final descripcion = conductasSeleccionadasLista.join(', ');
                    final comentario = comentarioController.text.trim();

                    await registrarConducta(
                      color: colorSeleccionado!,
                      descripcion: descripcion,
                      comentario: comentario,
                      alumno: alumno,
                    );

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Registro guardado de ${alumno['nombre']} ${alumno['apellido']}',
                        ),
                      ),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
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
            title: Text('Grado: $grado'),
            children: secciones.entries.map((seccionEntry) {
              final seccion = seccionEntry.key;
              final alumnos = seccionEntry.value;

              return ExpansionTile(
                title: Text(
                  'Sección: ${seccion[0].toUpperCase()}${seccion.substring(1)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
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
                                          size: 22,
                                        ),
                                        onPressed: () =>
                                            mostrarDialogoClasificacion(alumno),
                                        tooltip: 'Marcar conducta verde',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.circle,
                                          color: Colors.amber,
                                          size: 22,
                                        ),
                                        onPressed: () =>
                                            mostrarDialogoClasificacion(alumno),
                                        tooltip: 'Marcar conducta amarillo',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.circle,
                                          color: Colors.red,
                                          size: 22,
                                        ),
                                        onPressed: () =>
                                            mostrarDialogoClasificacion(alumno),
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
