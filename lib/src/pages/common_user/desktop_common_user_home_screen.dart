import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:registro_anecdotico/src/pages/admin_user/lista_alumnos_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/config_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/historial_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/records_summary_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/edit_list_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/users_list_screen.dart';

class DesktopAdminHomeUserScreen extends StatefulWidget {
  const DesktopAdminHomeUserScreen({super.key});

  @override
  State<DesktopAdminHomeUserScreen> createState() =>
      _DesktopAdminHomeUserScreenState();
}

class _DesktopAdminHomeUserScreenState
    extends State<DesktopAdminHomeUserScreen> {
  int selectedIndex = 0;
  final String uidActual = FirebaseAuth.instance.currentUser?.uid ?? '';

  Widget _mostrarContenido() {
    switch (selectedIndex) {
      case 0:
        return _paginaInicio();
      case 1:
        return const RecordsSummaryScreen(); // Antes era Registros
      case 2:
        return const HistorialScreen();
      case 3:
        return const EditListScreen(); // Antes era Lista de alumnos
      case 4:
        return const UserListScreen(); // Antes era Usuarios
      case 5:
        return const ConfigScreen();
      default:
        return const Center(child: Text("Selecciona una opción"));
    }
  }

  Widget _paginaInicio() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Buscar Alumno",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildBuscarAlumnoForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBuscarAlumnoForm() {
    final TextEditingController _nombreCtrl = TextEditingController();
    final TextEditingController _apellidoCtrl = TextEditingController();
    String? _gradoSeleccionado = '7';
    String? _seccionSeleccionada = 'A';
    final List<String> grados = ['7', '8', '9', '1', '2', '3'];
    final Map<String, List<String>> seccionesPorGrado = {
      '7': ['A', 'B'],
      '8': ['A', 'B'],
      '9': ['A', 'B'],
      '1': ['Informática', 'Ciencias Básicas'],
      '2': ['Informática', 'Ciencias Básicas'],
      '3': ['Informática', 'Ciencias Básicas'],
    };

    String normalizar(String texto) {
      texto = texto.toLowerCase();
      texto = texto
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ñ', 'n');
      return texto.trim();
    }

    Future<void> _buscarAlumno() async {
      final nombreBusq = normalizar(_nombreCtrl.text);
      final apellidoBusq = normalizar(_apellidoCtrl.text);
      final gradoBusq = _gradoSeleccionado;
      final seccionBusq = normalizar(_seccionSeleccionada ?? '');

      if (nombreBusq.isEmpty ||
          apellidoBusq.isEmpty ||
          gradoBusq == null ||
          seccionBusq.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Complete todos los campos")),
        );
        return;
      }

      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('students')
            .get();

        final listaFiltrada = snapshot.docs
            .map((doc) {
              final data = doc.data();
              final nombreDb = normalizar(data['nombre'] ?? '');
              final apellidoDb = normalizar(data['apellido'] ?? '');
              final gradoDb = (data['grado'] ?? '').toString().trim();
              final seccionDb = normalizar(data['seccion'] ?? '');

              if (nombreDb == nombreBusq &&
                  apellidoDb == apellidoBusq &&
                  gradoDb == gradoBusq &&
                  seccionDb == seccionBusq) {
                final alumnoConId = Map<String, dynamic>.from(data);
                alumnoConId['docId'] = doc.id;
                return alumnoConId;
              }
              return null;
            })
            .where((alumno) => alumno != null)
            .cast<Map<String, dynamic>>()
            .toList();

        if (listaFiltrada.isNotEmpty) {
          final estudiante = listaFiltrada.first;

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => RegistrarConductaDialog(
              alumno: estudiante,
              grado: estudiante['grado'].toString(),
              seccion: estudiante['seccion'],
              nivel: estudiante['nivel'] ?? 'Nivel desconocido',
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se encontró al alumno")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al buscar alumno: $e")));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nombreCtrl,
          decoration: const InputDecoration(labelText: "Nombre"),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _apellidoCtrl,
          decoration: const InputDecoration(labelText: "Apellido"),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _gradoSeleccionado,
          items: grados
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (value) {
            setState(() {
              _gradoSeleccionado = value;
              _seccionSeleccionada = seccionesPorGrado[value!]!.first;
            });
          },
          decoration: const InputDecoration(labelText: "Grado"),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _seccionSeleccionada,
          items: seccionesPorGrado[_gradoSeleccionado]!
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (value) => setState(() => _seccionSeleccionada = value),
          decoration: const InputDecoration(labelText: "Sección"),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _buscarAlumno,
          child: const Text("Buscar alumno"),
        ),
      ],
    );
  }

  bool mostrarRegistrosRecientes =
      true; // variable de estado de panel de regiistros recientes

  @override
  Widget build(BuildContext context) {
    const miColor = Color(0xFF8e0b13);

    return Scaffold(
      body: Row(
        children: [
          // Panel lateral
          Container(
            width: 250,
            color: Colors.grey.shade100,
            child: Column(
              children: [
                Container(
                  color: miColor,
                  height: 80,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.school, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        "Registro Anecdótico",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text("Inicio"),
                  trailing: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => setState(() => selectedIndex = 5),
                  ),
                  onTap: () => setState(() => selectedIndex = 0),
                ),
                ListTile(
                  title: const Text("Historial"),
                  onTap: () => setState(() => selectedIndex = 2),
                ),
              ],
            ),
          ),

          const VerticalDivider(thickness: 1, width: 1),

          // Contenido principal
          Expanded(child: _mostrarContenido()),

          const VerticalDivider(thickness: 1, width: 1),

          // Panel de historial personal
          /*Container(
            width: 300,
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "📋 Mi Historial",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('records')
                        .where(
                          'userId',
                          isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                        )
                        .orderBy('fecha', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final registros = snapshot.data!.docs;
                      if (registros.isEmpty) {
                        return const Center(
                          child: Text("No tienes registros en tu historial."),
                        );
                      }

                      return ListView.builder(
                        itemCount: registros.length,
                        itemBuilder: (context, index) {
                          final registro =
                              registros[index].data() as Map<String, dynamic>;
                          final studentId = registro['studentId'];

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('students')
                                .doc(studentId)
                                .get(),
                            builder: (context, studentSnapshot) {
                              if (!studentSnapshot.hasData) {
                                return const ListTile(
                                  title: Text("Cargando..."),
                                );
                              }
                              if (!studentSnapshot.data!.exists) {
                                return const ListTile(
                                  title: Text("Alumno no encontrado"),
                                );
                              }

                              final alumno =
                                  studentSnapshot.data!.data()
                                      as Map<String, dynamic>? ??
                                  {};
                              final nombre = alumno['nombre'] ?? '';
                              final apellido = alumno['apellido'] ?? '';
                              final grado = alumno['grado'] ?? '';
                              final seccion = alumno['seccion'] ?? '';

                              Color colorCard;
                              switch (registro['color']) {
                                case 'verde':
                                  colorCard = Colors.green.shade100;
                                  break;
                                case 'amarillo':
                                  colorCard = Colors.amber.shade100;
                                  break;
                                case 'rojo':
                                  colorCard = Colors.red.shade100;
                                  break;
                                default:
                                  colorCard = Colors.grey.shade100;
                              }

                              return Card(
                                color: colorCard,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text("$nombre $apellido"),
                                  subtitle: Text(
                                    "Grado: $grado - Sección: $seccion\n${registro['descripcion'] ?? ''}",
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),*/
        ],
      ),
    );
  }
}

// --- RegistrarConductaDialog ---
class RegistrarConductaDialog extends StatefulWidget {
  final Map<String, dynamic> alumno;
  final String grado;
  final String seccion;
  final String nivel;

  const RegistrarConductaDialog({
    super.key,
    required this.alumno,
    required this.grado,
    required this.seccion,
    required this.nivel,
  });

  @override
  State<RegistrarConductaDialog> createState() =>
      _RegistrarConductaDialogState();
}

class _RegistrarConductaDialogState extends State<RegistrarConductaDialog> {
  final _formKey = GlobalKey<FormState>();
  String? colorSeleccionado;
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

  late Map<String, bool> conductasSeleccionadas;
  bool otrosSeleccionado = false;
  Map<String, String> usuarioActual = {
    'nombre': '',
    'apellido': '',
    'rolReal': '',
  };

  @override
  void initState() {
    super.initState();
    conductasSeleccionadas = {for (var c in conductasFrecuentes) c: false};
    cargarUsuarioActual();
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
        usuarioActual['nombre'] = data['nombre'] ?? '';
        usuarioActual['apellido'] = data['apellido'] ?? '';
        usuarioActual['rolReal'] = data['rolReal'] ?? '';
      });
    }
  }

  Future<void> registrarConducta() async {
    if (!_formKey.currentState!.validate()) return;
    if (colorSeleccionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione un color')));
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione al menos una conducta o escriba en Otros'),
        ),
      );
      return;
    }

    final descripcion = listaConductas.map((c) => '• $c').join('\n');
    final comentario = comentarioController.text.trim();
    final usuarioActualFirebase = FirebaseAuth.instance.currentUser;
    final String uidUsuario = usuarioActualFirebase?.uid ?? 'desconocido';

    final registro = {
      'studentId': widget.alumno['docId'],
      'fecha': DateTime.now(),
      'color': colorSeleccionado,
      'descripcion': descripcion,
      'comentario': comentario,
      'grado': widget.grado,
      'seccion': widget.seccion,
      'nivel': widget.nivel,
      'registrado_por':
          '${usuarioActual['nombre']} ${usuarioActual['apellido']} ${usuarioActual['rolReal']}',
      'registradoPor': usuarioActual['rolReal'],
      'userId': uidUsuario,
    };

    await FirebaseFirestore.instance.collection('records').add(registro);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: 500,
          height: 600,
          child: Column(
            children: [
              const Text(
                "Registrar Conducta",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "${widget.alumno['nombre']} ${widget.alumno['apellido']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Grado: ${widget.grado} - Sección: ${widget.seccion} - Nivel: ${widget.nivel}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              "Clasificación: ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildColorCircle("verde", Colors.green),
                            _buildColorCircle("amarillo", Colors.amber),
                            _buildColorCircle("rojo", Colors.red),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...conductasFrecuentes.map(
                          (c) => CheckboxListTile(
                            title: Text(c),
                            value: conductasSeleccionadas[c],
                            onChanged: (v) =>
                                setState(() => conductasSeleccionadas[c] = v!),
                          ),
                        ),
                        CheckboxListTile(
                          title: const Text("Otros"),
                          value: otrosSeleccionado,
                          onChanged: (v) =>
                              setState(() => otrosSeleccionado = v!),
                        ),
                        if (otrosSeleccionado)
                          TextField(
                            controller: otrosController,
                            decoration: const InputDecoration(
                              labelText: "Escriba Otros",
                            ),
                          ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: comentarioController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: "Comentario / Reflexión",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: registrarConducta,
                    child: const Text("Guardar"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(String colorName, Color color) {
    return GestureDetector(
      onTap: () => setState(() => colorSeleccionado = colorName),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: colorSeleccionado == colorName
              ? Border.all(color: Colors.black, width: 2)
              : null,
        ),
      ),
    );
  }
}
