import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'historial_screen.dart';
import 'config_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/lista_alumnos_screen.dart';

class DesktopAdminHomeScreen extends StatefulWidget {
  const DesktopAdminHomeScreen({super.key});

  @override
  State<DesktopAdminHomeScreen> createState() => _DesktopAdminHomeScreenState();
}

class _DesktopAdminHomeScreenState extends State<DesktopAdminHomeScreen> {
  int selectedIndex = 0;

  Widget _mostrarContenido() {
    switch (selectedIndex) {
      case 0:
        return _paginaInicio();
      case 1:
        return const Center(
          child: Text("📂 Registros", style: TextStyle(fontSize: 18)),
        );
      case 2:
        return const HistorialScreen();
      case 3:
        return const Center(
          child: Text("🎓 Lista de alumnos", style: TextStyle(fontSize: 18)),
        );
      case 4:
        return const Center(
          child: Text("👥 Usuarios", style: TextStyle(fontSize: 18)),
        );
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
              height: 360, // <-- altura total de la Card
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

  // Formulario vertical
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

    // Función para normalizar texto
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

  @override
  Widget build(BuildContext context) {
    const miColor = Color(0xFF8e0b13);

    return Scaffold(
      body: Row(
        children: [
          // Menú lateral izquierdo
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
                    onPressed: () {
                      setState(() {
                        selectedIndex = 5;
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                ),
                ListTile(
                  title: const Text("Registros"),
                  onTap: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                ),
                ListTile(
                  title: const Text("Historial"),
                  onTap: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  },
                ),
                ListTile(
                  title: const Text("Lista de Alumnos"),
                  onTap: () {
                    setState(() {
                      selectedIndex = 3;
                    });
                  },
                ),
                ListTile(
                  title: const Text("Usuarios"),
                  onTap: () {
                    setState(() {
                      selectedIndex = 4;
                    });
                  },
                ),
              ],
            ),
          ),

          const VerticalDivider(thickness: 1, width: 1),

          // Contenido central
          Expanded(child: _mostrarContenido()),

          const VerticalDivider(thickness: 1, width: 1),

          // Panel derecho con registros recientes
          Container(
            width: 300,
            color: Colors.grey.shade200,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "📋 Registros Recientes",
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
                        .orderBy('fecha', descending: true)
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final registros = snapshot.data!.docs;
                      if (registros.isEmpty) {
                        return const Center(
                          child: Text("No hay registros recientes."),
                        );
                      }

                      return ListView.builder(
                        itemCount: registros.length,
                        itemBuilder: (context, index) {
                          final registro =
                              registros[index].data() as Map<String, dynamic>;
                          final studentId = registro['studentid'];

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

                              final studentData =
                                  studentSnapshot.data!.data()
                                      as Map<String, dynamic>? ??
                                  {};

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
                                  title: Text(
                                    "${studentData['nombre'] ?? ''} ${studentData['apellido'] ?? ''}",
                                  ),
                                  subtitle: Text(
                                    "Grado: ${registro['grado']} - Sección: ${registro['seccion']}\n${registro['descripcion']}",
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(Icons.arrow_forward),
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
          ),
        ],
      ),
    );
  }
}
