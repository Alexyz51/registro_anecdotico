import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/src/pages/admin_user/lista_alumnos_screen.dart';

class AdminUserHomeScreen extends StatefulWidget {
  const AdminUserHomeScreen({super.key});

  @override
  State<AdminUserHomeScreen> createState() => _AdminUserHomeScreenState();
}

class _AdminUserHomeScreenState extends State<AdminUserHomeScreen> {
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
