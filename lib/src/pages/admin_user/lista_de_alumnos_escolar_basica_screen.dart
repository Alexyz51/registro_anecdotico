import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/common_user/common_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/widgets/breadcrumb_navigation.dart';
import 'package:registro_anecdotico/src/pages/admin_user/escolar_basica.dart';

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

  // Función para registrar conducta en Firestore
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
      'nivel': alumno['nivel'] ?? 'escolar basica',
      'registrado_por':
          '${usuarioActual['nombre']} ${usuarioActual['apellido']} ${usuarioActual['rolReal']}',
      'registradoPor': usuarioActual['rolReal'],
      'userId': uidUsuario,
    };

    await FirebaseFirestore.instance.collection('conductas').add(registro);
  }

  // Función para mostrar el diálogo de clasificación
  Future<void> mostrarDialogoClasificacion(Map<String, dynamic> alumno) async {
    String? colorSeleccionado;
    final _formKey = GlobalKey<FormState>();
    final TextEditingController comentarioController = TextEditingController();
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
    final TextEditingController otrosController = TextEditingController();
    final scaffoldContext = context;

    await showDialog(
      context: context,
      builder: (contextDialog) {
        final anchoPantalla = MediaQuery.of(context).size.width;
        final anchoDialogo = anchoPantalla < 600 ? anchoPantalla * 0.95 : 500.0;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Registrar conducta'),
              content: SizedBox(
                width: anchoDialogo,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Clasificación
                          const Text(
                            'Clasificación',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildColorCircle(
                                colorName: 'verde',
                                colorSeleccionado: colorSeleccionado,
                                onTap: () => setStateDialog(
                                  () => colorSeleccionado = 'verde',
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildColorCircle(
                                colorName: 'amarillo',
                                colorSeleccionado: colorSeleccionado,
                                onTap: () => setStateDialog(
                                  () => colorSeleccionado = 'amarillo',
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildColorCircle(
                                colorName: 'rojo',
                                colorSeleccionado: colorSeleccionado,
                                onTap: () => setStateDialog(
                                  () => colorSeleccionado = 'rojo',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Descripción de suceso
                          const Text(
                            'Descripción del suceso:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...conductasFrecuentes.map(
                            (c) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: CheckboxListTile(
                                title: Text(c),
                                value: conductasSeleccionadas[c],
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (v) => setStateDialog(
                                  () => conductasSeleccionadas[c] = v ?? false,
                                ),
                              ),
                            ),
                          ),
                          CheckboxListTile(
                            title: const Text('Otros'),
                            value: otrosSeleccionado,
                            onChanged: (v) {
                              setStateDialog(() {
                                otrosSeleccionado = v ?? false;
                                if (!otrosSeleccionado) otrosController.clear();
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (otrosSeleccionado)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TextFormField(
                                controller: otrosController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  labelText: 'Describa la conducta',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (otrosSeleccionado &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Debe describir la conducta';
                                  }
                                  return null;
                                },
                              ),
                            ),

                          // Comentario / reflexión
                          TextFormField(
                            controller: comentarioController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Sugerencias / Reflexión',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingrese sugerencia o reflexión';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
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
                    if (!_formKey.currentState!.validate()) return;
                    if (colorSeleccionado == null) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(content: Text('Seleccione un color')),
                      );
                      return;
                    }

                    List<String> listaConductas = conductasSeleccionadas.entries
                        .where((e) => e.value)
                        .map((e) => e.key)
                        .toList();

                    if (otrosSeleccionado && otrosController.text.isNotEmpty) {
                      listaConductas.add(otrosController.text.trim());
                    }

                    if (listaConductas.isEmpty) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Seleccione al menos una conducta o escriba en Otros',
                          ),
                        ),
                      );
                      return;
                    }

                    final descripcion = listaConductas
                        .map((c) => '• $c')
                        .join('\n');
                    final comentario = comentarioController.text.trim();

                    await registrarConducta(
                      color: colorSeleccionado!,
                      descripcion: descripcion,
                      comentario: comentario,
                      alumno: alumno,
                    );

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

  Widget _buildColorCircle({
    required String colorName,
    required String? colorSeleccionado,
    required VoidCallback onTap,
  }) {
    Color color;
    switch (colorName) {
      case 'verde':
        color = Colors.green;
        break;
      case 'amarillo':
        color = Colors.amber;
        break;
      case 'rojo':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: color,
        radius: 12,
        child: colorSeleccionado == colorName
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
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
        automaticallyImplyLeading: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(color: rojoOscuro, height: 5.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Padding(
            padding: const EdgeInsets.all(16),
            child: BreadcrumbBar(
              items: [
                BreadcrumbItem(
                  recorrido: 'Inicio',
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
                BreadcrumbItem(
                  recorrido: 'Escolar Básica',
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EscolarBasicaScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                BreadcrumbItem(recorrido: 'Lista', onTap: () {}),
              ],
            ),
          ),

          // Texto de grado y sección
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${widget.grado}° Grado  - Sección ${widget.seccion.toUpperCase()}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
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
          Expanded(
            child: ListView.builder(
              itemCount: alumnosFiltrados.length,
              itemBuilder: (context, index) {
                final alumno = alumnosFiltrados[index];
                final color = index % 2 == 0 ? Colors.grey[100] : Colors.white;
                return GestureDetector(
                  onTap: () => mostrarDialogoClasificacion(alumno),
                  child: Container(
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
                        Expanded(flex: 3, child: Text(alumno['nombre'] ?? '')),
                        Expanded(
                          flex: 3,
                          child: Text(alumno['apellido'] ?? ''),
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
