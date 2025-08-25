import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  bool estaCargando = true;
  List<Map<String, dynamic>> registros = [];
  Map<String, String> usuarioActual = {};

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() => estaCargando = true);

    final User? usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      setState(() {
        registros = [];
        estaCargando = false;
      });
      return;
    }

    // Cargar usuario actual
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(usuario.uid)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      usuarioActual = {
        'nombre': data['nombre'] ?? '',
        'apellido': data['apellido'] ?? '',
        'rol': data['rol'] ?? '',
        'rolReal': data['rolReal'] ?? '',
      };
    }

    // Trae solo registros creados por este usuario
    final snapshot = await FirebaseFirestore.instance
        .collection('records')
        .where('userId', isEqualTo: usuario.uid)
        .get();

    final lista = await Future.wait(
      snapshot.docs.map((doc) async {
        final data = doc.data();
        data['docId'] = doc.id;

        if (data['studentId'] != null) {
          final alumnoDoc = await FirebaseFirestore.instance
              .collection('students')
              .doc(data['studentId'])
              .get();
          final alumno = alumnoDoc.data();
          data['nombre'] = alumno?['nombre'] ?? '';
          data['apellido'] = alumno?['apellido'] ?? '';
          data['grado'] = alumno?['grado'] ?? '';
          data['seccion'] = alumno?['seccion'] ?? '';
        } else {
          data['nombre'] = '';
          data['apellido'] = '';
          data['grado'] = '';
          data['seccion'] = '';
        }

        return data;
      }),
    );

    // Ordena por fecha descendente
    lista.sort((a, b) {
      final fechaA = a['fecha']?.toDate() ?? DateTime(2000);
      final fechaB = b['fecha']?.toDate() ?? DateTime(2000);
      return fechaB.compareTo(fechaA);
    });

    if (!mounted) return; // <--- verificar antes de setState final
    setState(() {
      registros = lista;
      estaCargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (estaCargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final isCelular = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: registros.length,
        itemBuilder: (context, index) {
          final registro = registros[index];
          final fecha = registro['fecha']?.toDate() ?? DateTime.now();

          String gradoFormateado = registro['grado'].toString();
          if (['1', '2', '3'].contains(gradoFormateado)) {
            gradoFormateado += '° curso';
          } else {
            gradoFormateado += '° grado';
          }

          String seccionFormateada = registro['seccion'].toString();
          if (seccionFormateada.isNotEmpty) {
            seccionFormateada =
                seccionFormateada[0].toUpperCase() +
                seccionFormateada.substring(1);
          }

          String nombre = registro['nombre'] ?? '';
          String apellido = registro['apellido'] ?? '';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ExpansionTile(
              title: isCelular
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$gradoFormateado - $seccionFormateada',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$nombre $apellido',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Text(
                      '$gradoFormateado - $seccionFormateada - $nombre $apellido',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
              subtitle: Text(
                'Fecha: ${fecha.day}/${fecha.month}/${fecha.year}',
                style: const TextStyle(fontSize: 12),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Color: ${registro['color'] ?? 'Sin color'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Descripción:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        registro['descripcion'] ?? '-',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Comentario / Reflexión:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        registro['comentario'] ?? '-',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF8e0b13), // mismo color del AppBar
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Cantidad de registros: ${registros.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
/*  @override
  Widget build(BuildContext context) {
    if (estaCargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final isCelular = MediaQuery.of(context).size.width < 600;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: registros.length,
      itemBuilder: (context, index) {
        final registro = registros[index];
        final fecha = registro['fecha']?.toDate() ?? DateTime.now();

        String gradoFormateado = registro['grado'].toString();
        if (['1', '2', '3'].contains(gradoFormateado)) {
          gradoFormateado += '° curso';
        } else {
          gradoFormateado += '° grado';
        }

        String seccionFormateada = registro['seccion'].toString();
        if (seccionFormateada.isNotEmpty) {
          seccionFormateada =
              seccionFormateada[0].toUpperCase() +
              seccionFormateada.substring(1);
        }

        String nombre = registro['nombre'] ?? '';
        String apellido = registro['apellido'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ExpansionTile(
            title: isCelular
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$gradoFormateado - $seccionFormateada',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$nombre $apellido',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                : Text(
                    '$gradoFormateado - $seccionFormateada - $nombre $apellido',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
            subtitle: Text(
              'Fecha: ${fecha.day}/${fecha.month}/${fecha.year}',
              style: const TextStyle(fontSize: 12),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color: ${registro['color'] ?? 'Sin color'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Descripción:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      registro['descripcion'] ?? '-',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Comentario / Reflexión:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      registro['comentario'] ?? '-',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}




/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/common_user/common_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/widgets/breadcrumb_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Función para obtener el usuario actual desde Firebase
Future<Map<String, String>> obtenerUsuarioActual() async {
  final User? usuario = FirebaseAuth.instance.currentUser;
  if (usuario == null) return {};

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(usuario.uid)
      .get();

  if (!doc.exists) return {};

  final data = doc.data()!;
  return {
    'nombre': data['nombre'] ?? '',
    'apellido': data['apellido'] ?? '',
    'rol': data['rol'] ?? '',
    'rolReal': data['rolReal'] ?? '',
  };
}

// Función para obtener información del alumno usando studentId
Future<Map<String, dynamic>> obtenerAlumno(String studentId) async {
  final doc = await FirebaseFirestore.instance
      .collection('students')
      .doc(studentId)
      .get();

  if (!doc.exists) return {};

  final data = doc.data()!;
  return {
    'nombre': data['nombre'] ?? '',
    'apellido': data['apellido'] ?? '',
    'grado': data['grado'] ?? '',
    'seccion': data['seccion'] ?? '',
  };
}

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  bool estaCargando = true;
  List<Map<String, dynamic>> registros = [];
  Map<String, String> usuarioActual = {};

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() => estaCargando = true);

    final User? usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      setState(() {
        registros = [];
        estaCargando = false;
      });
      return;
    }

    // Cargar usuario actual
    usuarioActual = await obtenerUsuarioActual();

    // Trae solo registros creados por este usuario
    final snapshot = await FirebaseFirestore.instance
        .collection('records')
        .where('userId', isEqualTo: usuario.uid) //filtro clave
        // .orderBy('fecha', descending: true) no se puede porque hay que indexar
        .get();

    // Obtener información del alumno para cada registro
    final lista = await Future.wait(
      snapshot.docs.map((doc) async {
        final data = doc.data();
        data['docId'] = doc.id;

        if (data['studentId'] != null) {
          final alumno = await obtenerAlumno(data['studentId']);
          data['nombre'] = alumno['nombre'] ?? '';
          data['apellido'] = alumno['apellido'] ?? '';
          data['grado'] = alumno['grado'] ?? '';
          data['seccion'] = alumno['seccion'] ?? '';
        } else {
          data['nombre'] = '';
          data['apellido'] = '';
          data['grado'] = '';
          data['seccion'] = '';
        }

        return data;
      }),
    );
    // Ordena por fecha descendente en memoria
    lista.sort((a, b) {
      final fechaA = a['fecha']?.toDate() ?? DateTime(2000);
      final fechaB = b['fecha']?.toDate() ?? DateTime(2000);
      return fechaB.compareTo(fechaA); // más reciente primero
    });
    setState(() {
      registros = lista;
      estaCargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (estaCargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isCelular = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (usuarioActual['rolReal'] == 'administrador') {
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
        title: const Text('Historial de Registros'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(248, 252, 230, 230),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: BreadcrumbBar(
              items: [
                BreadcrumbItem(
                  recorrido: 'Inicio',
                  onTap: () {
                    if (usuarioActual['rolReal'] == 'administrador') {
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
                BreadcrumbItem(recorrido: 'Historial de Registros'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: registros.length,
              itemBuilder: (context, index) {
                final registro = registros[index];
                final fecha = registro['fecha']?.toDate() ?? DateTime.now();

                // Formateo del grado
                String gradoFormateado = registro['grado'].toString();
                if (['1', '2', '3'].contains(gradoFormateado)) {
                  gradoFormateado += '° curso';
                } else {
                  gradoFormateado += '° grado';
                }

                // Sección con primera letra en mayúscula
                String seccionFormateada = registro['seccion'].toString();
                if (seccionFormateada.isNotEmpty) {
                  seccionFormateada =
                      seccionFormateada[0].toUpperCase() +
                      seccionFormateada.substring(1);
                }

                String nombre = registro['nombre'] ?? '';
                String apellido = registro['apellido'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: isCelular
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$gradoFormateado - $seccionFormateada',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '$nombre $apellido',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '$gradoFormateado - $seccionFormateada - $nombre $apellido',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                    subtitle: Text(
                      'Fecha: ${fecha.day}/${fecha.month}/${fecha.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Color: ${registro['color'] ?? 'Sin color'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Descripción:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              registro['descripcion'] ?? '-',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Comentario / Reflexión:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              registro['comentario'] ?? '-',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                          ],
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
    );
  }
}
*/*/