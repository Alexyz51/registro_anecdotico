import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/src/pages/admin_user/lista_alumnos_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'historial_screen.dart';

class AdminUserHomeScreen extends StatefulWidget {
  const AdminUserHomeScreen({super.key});

  @override
  State<AdminUserHomeScreen> createState() => _AdminUserHomeScreenState();
}

class _AdminUserHomeScreenState extends State<AdminUserHomeScreen> {
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
    final nombreBusq = _nombreCtrl.text.trim().toLowerCase();
    final apellidoBusq = _apellidoCtrl.text.trim().toLowerCase();
    final gradoBusq = _gradoSeleccionado;
    final seccionBusq = _seccionSeleccionada?.toLowerCase();

    if (nombreBusq.isEmpty ||
        apellidoBusq.isEmpty ||
        gradoBusq == null ||
        seccionBusq == null) {
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
            final nombreDb = (data['nombre'] ?? '')
                .toString()
                .toLowerCase()
                .trim();
            final apellidoDb = (data['apellido'] ?? '')
                .toString()
                .toLowerCase()
                .trim();
            final gradoDb = data['grado']?.toString().trim();
            final seccionDb = (data['seccion'] ?? '')
                .toString()
                .toLowerCase()
                .trim();

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
    const cremita = Color.fromARGB(248, 252, 230, 230);
    const miColor = Color(0xFF8e0b13);

    return Scaffold(
      backgroundColor: cremita,
      appBar: AppBar(
        backgroundColor: miColor,
        title: const Text(
          "Registro Anecdótico",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('login');
              } else if (value == 'delete') {
                // lógica eliminación
              } else if (value == 'reportes') {
                Navigator.pushNamed(context, 'records_summary');
              } else if (value == 'usuarios') {
                Navigator.pushNamed(context, 'users_list');
              } else if (value == 'about') {
                Navigator.pushNamed(context, 'about_app');
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: 'logout', child: Text("Cerrar sesión")),
                PopupMenuItem(value: 'delete', child: Text("Eliminar cuenta")),
                PopupMenuItem(value: 'reportes', child: Text("Reportes")),
                PopupMenuItem(value: 'usuarios', child: Text("Usuarios")),
                PopupMenuItem(value: 'about', child: Text("Acerca de")),
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
                _paginaConfiguracion(),
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
              _buildTextField(_nombreCtrl, "Nombre del alumno"),
              const SizedBox(height: 16),
              _buildTextField(_apellidoCtrl, "Apellido del alumno"),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gradoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Grado',
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
  }

  Widget _paginaConfiguracion() => const Center(child: Text("Configuración"));

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

/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/src/pages/admin_user/lista_alumnos_screen.dart';
import '../widgets/breadcrumb_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUserHomeScreen extends StatefulWidget {
  const AdminUserHomeScreen({super.key});

  @override
  State<AdminUserHomeScreen> createState() => _AdminUserHomeScreenState();
}

class _AdminUserHomeScreenState extends State<AdminUserHomeScreen> {
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
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 300,
              maxWidth: 400,
              maxHeight: 400, // Un poco más alto para mejor scroll
            ),
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Por favor, selecciona tu cargo'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Cargo',
                          border: OutlineInputBorder(),
                        ),
                        isExpanded: true,
                        items: cargos
                            .map(
                              (cargo) => DropdownMenuItem(
                                value: cargo,
                                child: Text(
                                  cargo,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                    ),
                  ],
                ),
              ),
            ),
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

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidoCtrl = TextEditingController();

  final List<String> gradosEscolarBasica = ['7', '8', '9', '1', '2', '3'];
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

  Future<void> _buscarAlumno() async {
    final nombreBusq = _nombreCtrl.text.trim().toLowerCase();
    final apellidoBusq = _apellidoCtrl.text.trim().toLowerCase();
    final gradoBusq = _gradoSeleccionado?.trim();
    final seccionBusq = _seccionSeleccionada?.trim().toLowerCase();

    if (nombreBusq.isEmpty ||
        apellidoBusq.isEmpty ||
        gradoBusq == null ||
        seccionBusq == null ||
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
            final nombreDb = (data['nombre'] ?? '')
                .toString()
                .toLowerCase()
                .trim();
            final apellidoDb = (data['apellido'] ?? '')
                .toString()
                .toLowerCase()
                .trim();
            final gradoDb = data['grado']?.toString().trim();
            final seccionDb = (data['seccion'] ?? '')
                .toString()
                .toLowerCase()
                .trim();

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
              alumno: estudiante, // el Map completo del alumno
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
    const cremita = Color.fromARGB(248, 252, 230, 230);
    const miColor = Color(0xFF8e0b13);

    return Scaffold(
      backgroundColor: cremita,
      drawer: Drawer(
        backgroundColor: miColor,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Encabezado con imagen y datos del usuario
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                color: miColor,
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/book.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (rolReal != null && nombre != null && apellido != null)
                      Text(
                        '$nombre $apellido\n$rolReal',
                        style: const TextStyle(
                          color: cremita,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      const Center(
                        child: CircularProgressIndicator(color: cremita),
                      ),
                  ],
                ),
              ),

              // Ítems del menú
              ListTile(
                tileColor: _itemSeleccionado == 'edit_list'
                    ? const Color.fromARGB(248, 252, 230, 230)
                    : null,
                leading: const Icon(Icons.edit, color: Colors.white),
                title: const Text(
                  'Editar lista',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _itemSeleccionado = 'edit_list'; // Actualiza el estado
                  });
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'edit_list');
                },
              ),
              ListTile(
                tileColor: _itemSeleccionado == 'historial'
                    ? const Color.fromARGB(248, 252, 230, 230)
                    : null,
                leading: const Icon(Icons.history, color: Colors.white),
                title: const Text(
                  'Historial',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _itemSeleccionado = 'historial'; // Actualiza el estado
                  });
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'historial');
                },
              ),
              ListTile(
                tileColor: _itemSeleccionado == 'about_app'
                    ? const Color.fromARGB(248, 252, 230, 230)
                    : null,
                leading: const Icon(Icons.summarize, color: Colors.white),
                title: const Text(
                  'Reportes',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _itemSeleccionado =
                        'records_summary'; // 👈 Actualiza el estado
                  });
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'records_summary');
                },
              ),
              ListTile(
                tileColor: _itemSeleccionado == 'users_list'
                    ? const Color.fromARGB(248, 252, 230, 230)
                    : null,
                leading: const Icon(Icons.people, color: Colors.white),
                title: const Text(
                  'Usuarios',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _itemSeleccionado = 'users_list'; // Actualiza el estado
                  });
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'users_list');
                },
              ),
              ListTile(
                tileColor: _itemSeleccionado == 'about_app'
                    ? const Color.fromARGB(248, 252, 230, 230)
                    : null,
                leading: const Icon(Icons.info, color: Colors.white),
                title: const Text(
                  'Acerca de',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    _itemSeleccionado = 'about_app'; // Actualiza el estado
                  });
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'about_app');
                },
              ),
              ListTile(
                tileColor: _itemSeleccionado == 'logout'
                    ? const Color.fromARGB(248, 252, 230, 230)
                    : null,
                leading: Icon(
                  Icons.logout,
                  color: _itemSeleccionado == 'logout'
                      ? Colors.black
                      : Colors.white,
                ),
                title: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: _itemSeleccionado == 'logout'
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
                onTap: () async {
                  setState(() {
                    _itemSeleccionado =
                        'logout'; // Marca este item como seleccionado
                  });
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacementNamed('login');
                },
              ),

              ListTile(
                tileColor: _itemSeleccionado == 'borrar_cuenta'
                    ? const Color.fromARGB(
                        248,
                        252,
                        230,
                        230,
                      ) // color cremita cuando está seleccionado
                    : null,
                leading: const Icon(
                  Icons.delete_forever,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                title: const Text(
                  'Borrar cuenta',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  setState(() {
                    _itemSeleccionado =
                        'borrar_cuenta'; // marcar como seleccionado
                  });

                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: const Text(
                        '¿Estás seguro de que quieres borrar tu cuenta? Esta acción no se puede deshacer.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Borrar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    try {
                      await FirebaseAuth.instance.currentUser!.delete();
                      Navigator.of(context).pushReplacementNamed('login');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No se pudo borrar la cuenta. Intenta cerrar sesión e iniciar nuevamente.',
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: miColor,
        title: const Text('Buscar Alumno'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_nombreCtrl, "Nombre del alumno"),
                const SizedBox(height: 16),
                _buildTextField(_apellidoCtrl, "Apellido del alumno"),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _gradoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Grado',
                    border: OutlineInputBorder(),
                  ),
                  items: gradosEscolarBasica
                      .map<DropdownMenuItem<String>>(
                        (g) =>
                            DropdownMenuItem<String>(value: g, child: Text(g)),
                      )
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
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: miColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _buscarAlumno,
                    child: const Text(
                      "Buscar alumno",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
*/
