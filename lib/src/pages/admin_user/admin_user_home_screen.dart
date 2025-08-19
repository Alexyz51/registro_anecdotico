import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/breadcrumb_navigation.dart';

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

  @override
  Widget build(BuildContext context) {
    String hexColor = '#8e0b13';
    int colorValue = int.parse(hexColor.substring(1), radix: 16);
    Color miColor = Color(colorValue | 0xFF000000);
    const cremita = const Color.fromARGB(248, 252, 230, 230);
    const rojoOscuro = Color.fromARGB(255, 39, 2, 2);
    //Paleta de colores habitual
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                    _itemSeleccionado = 'edit_list'; // 👈 Actualiza el estado
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
                    _itemSeleccionado = 'historial'; // 👈 Actualiza el estado
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
                    _itemSeleccionado = 'users_list'; // 👈 Actualiza el estado
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
                    _itemSeleccionado = 'about_app'; // 👈 Actualiza el estado
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
        backgroundColor: cremita,
        iconTheme: IconThemeData(color: rojoOscuro),
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
        elevation: 0, // para que no tenga sombra propia
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0), // altura de la barra separadora
          child: Container(
            color: rojoOscuro, // tu color rojo oscuro declarado
            height: 5.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BreadcrumbBar(
              items: [
                BreadcrumbItem(
                  recorrido: 'Secciones',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'admin_home');
                  },
                ),
              ],
            ),
            // Barrita fina separadora
            /*Align(
              alignment: Alignment.center,
              child: Container(
                height: 1.0,
                width:
                    2900, // Cambiá este valor para que sea más larga o más corta
                color: rojoOscuro,
              ),
            ),*/
            const SizedBox(height: 30),
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Ancho máximo del botón: 400 en PC, 90% en móvil
                  double buttonWidth = constraints.maxWidth > 600
                      ? 400
                      : constraints.maxWidth * 0.9;

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: buttonWidth,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: miColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, 'escolar_basica');
                            },
                            child: const Text(
                              'Escolar básica',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: buttonWidth,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: miColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, 'nivel_medio');
                            },
                            child: const Text(
                              'Nivel medio',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
