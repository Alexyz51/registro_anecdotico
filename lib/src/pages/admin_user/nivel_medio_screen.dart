/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/common_user/common_user_home_screen.dart';
import 'package:logger/logger.dart';
import 'package:registro_anecdotico/src/pages/widgets/breadcrumb_navigation.dart';

class NivelMedioScreen extends StatefulWidget {
  const NivelMedioScreen({super.key});

  @override
  State<NivelMedioScreen> createState() => _NivelMedioScreenState();
}

class _NivelMedioScreenState extends State<NivelMedioScreen> {
  final Logger logger = Logger();
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
    User? usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      // No hay usuario autenticado
      logger.w('No hay usuario autenticado');
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
        usuarioActual['rol'] = data['rol'] ?? '';
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
    final usuarioActualFirebase = FirebaseAuth.instance.currentUser;
    final String uidUsuario = usuarioActualFirebase?.uid ?? 'desconocido';

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
          '${usuarioActual['nombre']} ${usuarioActual['apellido']} ${usuarioActual['rolReal']}',
      // Solo rol real (sin nombre ni apellido) con P mayúscula:
      'registradoPor': usuarioActual['rolReal'],
      // UID con guion bajo y todo en minúscula:
      'userId': uidUsuario,
    };

    await FirebaseFirestore.instance.collection('records').add(registro);
  }

  Future<void> mostrarDialogoClasificacion(Map<String, dynamic> alumno) async {
    String? colorSeleccionado;
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

    Map<String, bool> conductasSeleccionadas = {
      for (var c in conductasFrecuentes) c: false,
    };
    bool otrosSeleccionado = false;

    // Contexto para SnackBar fuera del diálogo
    final scaffoldContext = context;

    await showDialog(
      context: context,
      builder: (contextDialog) {
        final screenWidth = MediaQuery.of(context).size.width;
        final dialogWidth = screenWidth > 600 ? 500.0 : screenWidth * 0.9;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Registrar conducta',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: dialogWidth,
                height: MediaQuery.of(context).size.height * 0.6,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
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
                          'Descripción del Suceso:',
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
                  onPressed: () => Navigator.pop(contextDialog),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      print('Validación falló');
                      return;
                    }

                    if (colorSeleccionado == null) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
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
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Debe seleccionar al menos una conducta o escribir en Otros',
                          ),
                        ),
                      );
                      return;
                    }

                    final descripcion = conductasSeleccionadasLista
                        .map((c) => '• $c')
                        .join('\n');
                    final comentario = comentarioController.text.trim();

                    try {
                      await registrarConducta(
                        color: colorSeleccionado!,
                        descripcion: descripcion,
                        comentario: comentario,
                        alumno: alumno,
                      );
                    } catch (e) {
                      print('Error guardando conducta: $e');
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(
                          content: Text('Error al guardar registro: $e'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(contextDialog);

                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
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
    const Color cremita = Color.fromARGB(248, 252, 230, 230);
    const rojoOscuro = Color.fromARGB(255, 39, 2, 2);

    if (estaCargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Map<String, Map<String, List>> seccionInformatica = {};
    Map<String, Map<String, List>> seccionEscolarBasica = {};

    datos.forEach((grado, secciones) {
      secciones.forEach((seccion, alumnos) {
        final seccionLower = seccion.toLowerCase();
        if (seccionLower == 'informatica') {
          seccionInformatica.putIfAbsent(grado, () => {});
          seccionInformatica[grado]![seccion] = alumnos;
        } else if (seccionLower == 'escolar basica') {
          seccionEscolarBasica.putIfAbsent(grado, () => {});
          seccionEscolarBasica[grado]![seccion] = alumnos;
        }
      });
    });

    Widget construirSeccion(
      String nombreSeccion,
      Map<String, Map<String, List>> data,
    ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              nombreSeccion,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...data.entries.map((gradoEntry) {
            final grado = gradoEntry.key;
            final secciones = gradoEntry.value;

            final List alumnosUnificados = secciones.values
                .expand((lista) => lista)
                .toList();

            return ExpansionTile(
              title: Text('$grado° Curso'),
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
                            width: 250,
                            child: Text(
                              'Nombre y Apellido',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: alumnosUnificados.length,
                  itemBuilder: (context, index) {
                    final alumno = alumnosUnificados[index];
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
                                  width: 250,
                                  child: GestureDetector(
                                    onTap: () =>
                                        mostrarDialogoClasificacion(alumno),
                                    child: Text(
                                      '${alumno['nombre']} ${alumno['apellido']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }).toList(),
        ],
      );
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
        automaticallyImplyLeading: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: rojoOscuro, height: 5.0),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: BreadcrumbBar(
              items: [
                BreadcrumbItem(
                  recorrido: 'Secciones',
                  onTap: () {
                    if (usuarioActual['rol'] == 'administrador') {
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
                BreadcrumbItem(recorrido: 'Lista de Escolar Básica'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                construirSeccion('Informatica', seccionInformatica),
                const SizedBox(height: 20),
                construirSeccion('Escolar Basica', seccionEscolarBasica),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
