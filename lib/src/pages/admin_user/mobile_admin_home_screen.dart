import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/src/pages/admin_user/lista_alumnos_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'historial_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/config_screen.dart';

class MobileAdminHomeScreen extends StatefulWidget {
  const MobileAdminHomeScreen({super.key});

  @override
  State<MobileAdminHomeScreen> createState() => _MobileAdminHomeScreenState();
}

class _MobileAdminHomeScreenState extends State<MobileAdminHomeScreen> {
  String? _itemSeleccionado;
  bool _cargando = true;
  String? _cargoSeleccionado;

  final List<String> cargos = [
    'Docente del Área Administrativa',
    'Docente de Lengua',
    'Docente de Matemática',
    'Docente de Ciencias Naturales',
    'Docente de Historia y Geografía',
    'Docente de Formación Ética',
    'Docente de Educación Física',
    'Docente de Artes',
    'Docente de Música',
    'Docente de Desarrollo Personal',
    'Docente de Informática',
    'Docente de Física y Química',
    'Docente de Economía y Gestión',
    'Docente de Orientación Educacional',
  ];

  String? nombre;
  String? apellido;
  String? rolReal;

  // controladores
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();

  final List<String> grados = ['7', '8', '9', '1', '2', '3'];
  final Map<String, List<String>> seccionesPorGrado = {
    '7': ['A', 'B'],
    '8': ['A', 'B'],
    '9': ['A', 'B'],
    '1': ['Informática', 'Ciencias Básicas'],
    '2': ['Informática', 'Ciencias Básicas'],
    '3': ['Informática', 'Ciencias Básicas'],
  };

  String? _gradoSeleccionado = '7';
  String? _seccionSeleccionada = 'A';

  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _verificarPrimerInicio();
    _cargarDatosUsuario();
  }

  Future<void> _verificarPrimerInicio() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['primerInicio'] == true) {
        _mostrarDialogoCargo();
      }
    }
    setState(() {
      _cargando = false;
    });
  }

  Future<void> _cargarDatosUsuario() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final data = snapshot.data();
      if (data != null) {
        setState(() {
          nombre = data['nombre'];
          apellido = data['apellido'];
          rolReal = data['rolReal'];
        });
      }
    }
  }

  void _mostrarDialogoCargo() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Es tu primera vez aquí'),
          content: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Cargo',
              border: OutlineInputBorder(),
            ),
            isExpanded: true,
            items: cargos
                .map(
                  (cargo) => DropdownMenuItem<String>(
                    value: cargo,
                    child: Text(cargo, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            value: _cargoSeleccionado,
            onChanged: (valor) {
              setState(() {
                _cargoSeleccionado = valor;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_cargoSeleccionado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor selecciona un cargo'),
                    ),
                  );
                  return;
                }
                final uid = FirebaseAuth.instance.currentUser!.uid;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({
                      'rolReal': _cargoSeleccionado,
                      'primerInicio': false,
                    });
                setState(() {
                  rolReal = _cargoSeleccionado;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _buscarAlumno() async {
    // Normaliza la función para quitar acentos
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListaAlumnosScreen(
              alumno: estudiante,
              grado: estudiante['grado'].toString(),
              seccion: estudiante['seccion'],
              nivel: estudiante['nivel'] ?? 'Nivel desconocido',
            ),
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

  @override
  Widget build(BuildContext context) {
    //const cremita = const Color(0xFFFFFDD0);
    const cremita = Colors.white;
    const miColor = Color(0xFF8e0b13);

    return Scaffold(
      backgroundColor: cremita,
      appBar: AppBar(
        backgroundColor: miColor,
        title: const Text(
          "Registro Anecdótico",
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'reportes') {
                Navigator.pushNamed(context, 'records_summary');
              } else if (value == 'usuarios') {
                Navigator.pushNamed(context, 'users_list');
              } else if (value == 'lista') {
                Navigator.pushNamed(context, 'edit_list');
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: 'lista', child: Text("Lista")),
                PopupMenuItem(value: 'reportes', child: Text("Reportes")),
                PopupMenuItem(value: 'usuarios', child: Text("Usuarios")),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Fila de iconos debajo del AppBar
          Container(
            color: miColor,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _iconoPagina(Icons.home, 0),
                _iconoPagina(Icons.history, 1),
                _iconoPagina(Icons.settings, 2),
              ],
            ),
          ),

          // PageView con swipe horizontal
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _paginaInicio(),
                const HistorialScreen(), // la página de historial dentro del PageView
                const ConfigScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconoPagina(IconData icono, int index) {
    const miColor = Color(0xFF8e0b13);
    return IconButton(
      icon: Icon(
        icono,
        color: Colors.white.withOpacity(_currentPage == index ? 1.0 : 0.5),
      ),
      onPressed: () {
        // Solo mueve el PageView al índice correspondiente
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  /*Widget _paginaInicio() {
    const miColor = Color(0xFF8e0b13);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /*Text(
                "Introduzca los datos para iniciar a registrar:",
                style: TextStyle(
                  color: miColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16), // separador*/
              _buildTextField(_nombreCtrl, "Nombre del alumno"),
              const SizedBox(height: 16),
              _buildTextField(_apellidoCtrl, "Apellido del alumno"),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gradoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Grado o Curso',
                  border: OutlineInputBorder(),
                ),
                items: grados
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gradoSeleccionado = value;
                    _seccionSeleccionada = seccionesPorGrado[value!]!.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _seccionSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Sección',
                  border: OutlineInputBorder(),
                ),
                items:
                    (_gradoSeleccionado != null
                            ? seccionesPorGrado[_gradoSeleccionado]!
                            : [])
                        .map<DropdownMenuItem<String>>(
                          (s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(s),
                          ),
                        )
                        .toList(),
                onChanged: (value) =>
                    setState(() => _seccionSeleccionada = value),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: miColor),
                onPressed: _buscarAlumno,
                child: const Text(
                  "Buscar alumno",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }*/

  Widget _paginaInicio() {
    const miColor = Color(0xFF8e0b13);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              /* Text(
                "Buscar alumno",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              */
              const SizedBox(height: 8),

              // Icono
              //const Icon(Icons.search, color: Colors.white, size: 48),
              //const SizedBox(height: 24),

              // Formulario
              const SizedBox(height: 16), // separador*/
              _buildTextField(_nombreCtrl, "Nombre del alumno"),
              const SizedBox(height: 16),
              _buildTextField(_apellidoCtrl, "Apellido del alumno"),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gradoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Grado o Curso',
                  border: OutlineInputBorder(),
                ),
                items: grados
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gradoSeleccionado = value;
                    _seccionSeleccionada = seccionesPorGrado[value!]!.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _seccionSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Sección',
                  border: OutlineInputBorder(),
                ),
                items:
                    (_gradoSeleccionado != null
                            ? seccionesPorGrado[_gradoSeleccionado]!
                            : [])
                        .map<DropdownMenuItem<String>>(
                          (s) => DropdownMenuItem<String>(
                            value: s,
                            child: Text(s),
                          ),
                        )
                        .toList(),
                onChanged: (value) =>
                    setState(() => _seccionSeleccionada = value),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: miColor),
                onPressed: _buscarAlumno,
                child: const Text(
                  "Buscar alumno",
                  style: TextStyle(color: Colors.white),
                ),
              ),

              // Instrucciones
              Text(
                "Introduce el nombre, apellido, grado y sección del alumno",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paginaConfiguracion() {
    const miColor = Color(0xFF8e0b13);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        const Divider(),
        // Acerca de la aplicación
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Acerca de la aplicación'),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Registro Anecdótico',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.book),
              children: const [
                Text(
                  'Esta aplicación permite gestionar registros anecdóticos de estudiantes.',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
