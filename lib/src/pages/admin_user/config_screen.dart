/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'about_app_screen.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  String nombre = '';
  String apellido = '';
  String cargo = '';
  String rolApp = '';

  bool estaCargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          nombre = data['nombre'] ?? '';
          apellido = data['apellido'] ?? '';
          cargo = data['rolReal'] ?? '';
          final rol = data['rol'] ?? '';
          rolApp = rol.isNotEmpty
              ? rol[0].toUpperCase() + rol.substring(1)
              : rol;
          estaCargando = false;
        });
      }
    }
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  Future<void> _eliminarCuenta() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      // Primero eliminar documentos relacionados si es necesario
      await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .delete();
      await usuario.delete();
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    const miColor = Color(0xFF8e0b13);

    if (estaCargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información del usuario
          ListTile(
            leading: CircleAvatar(
              radius: 25, // tamaño del círculo
              backgroundColor: Colors.white24, // color de fondo del círculo
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            tileColor: miColor,
            title: Text(
              '$nombre $apellido',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '$cargo - $rolApp',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 20),

          // Opciones de configuración
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar sesión'),
              onTap: _cerrarSesion,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Eliminar cuenta'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Confirmar eliminación'),
                    content: const Text(
                      '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _eliminarCuenta();
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('Acerca de la aplicación'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutAppScreen(),
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
*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'about_app_screen.dart';
import 'package:registro_anecdotico/main.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  String nombre = '';
  String apellido = '';
  String cargo = '';
  String rolApp = '';
  bool estaCargando = true;

  // -------------------- DARK MODE --------------------
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();

    // Inicializamos el switch de tema según el estado actual de MyApp
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        darkMode = MyApp.of(context)?.themeMode == ThemeMode.dark;
      });
    });
  }

  Future<void> _cargarDatosUsuario() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          nombre = data['nombre'] ?? '';
          apellido = data['apellido'] ?? '';
          cargo = data['rolReal'] ?? '';
          final rol = data['rol'] ?? '';
          rolApp = rol.isNotEmpty
              ? rol[0].toUpperCase() + rol.substring(1)
              : rol;
          estaCargando = false;
        });
      }
    }
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, 'login');
  }

  Future<void> _eliminarCuenta() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(usuario.uid)
          .delete();
      await usuario.delete();
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  // -------------------- EXPORTAR CSV --------------------
  Future<String> exportRecordsToCSV() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('records')
        .get();
    final registros = snapshot.docs;

    if (registros.isEmpty) return '';

    List<List<String>> csvData = [
      [
        'Alumno',
        'Grado',
        'Sección',
        'Nivel',
        'Color',
        'Descripción',
        'Comentario',
        'Fecha',
        'Registrado_por',
        'UserId',
      ],
    ];

    for (var doc in registros) {
      final data = doc.data();
      csvData.add([
        data['studentName'] ?? '',
        data['grado'] ?? '',
        data['seccion'] ?? '',
        data['nivel'] ?? '',
        data['color'] ?? '',
        data['descripcion'] ?? '',
        data['comentario'] ?? '',
        data['fecha'] != null
            ? (data['fecha'] as Timestamp).toDate().toString()
            : '',
        data['registrado_por'] ?? '',
        data['userId'] ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/registro_export_${DateTime.now().toIso8601String()}.csv';
    final file = File(path);
    await file.writeAsString(csv);
    return path;
  }

  // -------------------- BORRAR REGISTROS --------------------
  Future<void> clearAllRecords() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('records')
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // -------------------- CONTADOR --------------------
  int daysUntilMonthEnd() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final difference = lastDayOfMonth.difference(now);
    return difference.inDays;
  }

  @override
  Widget build(BuildContext context) {
    const miColor = Color(0xFF8e0b13);

    if (estaCargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Información del usuario
          ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white24,
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            tileColor: miColor,
            title: Text(
              '$nombre $apellido',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '$cargo - $rolApp',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(height: 20),

          // -------------------- SWITCH MODO OSCURO --------------------
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode, color: Colors.blueGrey),
              title: const Text('Modo oscuro'),
              trailing: Switch(
                value: darkMode,
                onChanged: (valor) {
                  setState(() => darkMode = valor);
                  if (valor) {
                    MyApp.of(context)?.changeTheme(ThemeMode.dark);
                  } else {
                    MyApp.of(context)?.changeTheme(ThemeMode.light);
                  }
                },
              ),
            ),
          ),

          // Contador de días hasta borrado mensual
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer, color: Colors.orange),
              title: Text(
                'Faltan ${daysUntilMonthEnd()} días para el borrado mensual',
              ),
            ),
          ),

          // Botón de exportar y borrar solo para administradores
          if (cargo.toLowerCase() == 'administrador')
            Card(
              child: ListTile(
                leading: const Icon(Icons.download, color: Colors.blue),
                title: const Text('Exportar y borrar registros'),
                onTap: () async {
                  final path = await exportRecordsToCSV();
                  await clearAllRecords();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Registros exportados y borrados. CSV: $path',
                      ),
                    ),
                  );
                  setState(() {}); // refrescar contador
                },
              ),
            ),

          // Opciones de configuración
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar sesión'),
              onTap: _cerrarSesion,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Eliminar cuenta'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Confirmar eliminación'),
                    content: const Text(
                      '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _eliminarCuenta();
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('Acerca de la aplicación'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutAppScreen(),
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
