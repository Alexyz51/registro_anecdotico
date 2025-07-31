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
  bool _cargando = true;
  String? _cargoSeleccionado;
  final List<String> cargosAdmin = [
    'Director',
    'Directora',
    'Secretario',
    'Secretaria',
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Por favor, selecciona tu cargo'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Cargo',
                  border: OutlineInputBorder(),
                ),
                items: cargosAdmin
                    .map(
                      (cargo) =>
                          DropdownMenuItem(value: cargo, child: Text(cargo)),
                    )
                    .toList(),
                value: _cargoSeleccionado,
                onChanged: (valor) {
                  setState(() {
                    _cargoSeleccionado = valor;
                  });
                },
              ),
            ],
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
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      drawer: Drawer(
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
                color: Theme.of(context).primaryColor,
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
                        '$rolReal $nombre $apellido',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                    else
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                  ],
                ),
              ),

              // Ítems del menú
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar lista'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'edit_list');
                },
              ),
              ListTile(
                leading: const Icon(Icons.supervised_user_circle_sharp),
                title: const Text('Usuarios'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'users_list');
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BreadcrumbBar(
          items: [
            BreadcrumbItem(
              recorrido: 'Inicio',
              onTap: () {
                Navigator.pushReplacementNamed(context, 'admin_home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
