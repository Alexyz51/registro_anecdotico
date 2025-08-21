import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegistrarConductaScreen extends StatefulWidget {
  final Map<String, dynamic> alumno;

  const RegistrarConductaScreen({super.key, required this.alumno});

  @override
  State<RegistrarConductaScreen> createState() =>
      _RegistrarConductaScreenState();
}

class _RegistrarConductaScreenState extends State<RegistrarConductaScreen> {
  String? colorSeleccionado;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController comentarioController = TextEditingController();
  final TextEditingController otrosController = TextEditingController();
  bool otrosSeleccionado = false;

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

  Map<String, bool> conductasSeleccionadas = {};

  @override
  void initState() {
    super.initState();
    conductasSeleccionadas = {for (var c in conductasFrecuentes) c: false};
  }

  Future<void> registrarConducta() async {
    final usuario = FirebaseAuth.instance.currentUser;
    final uidUsuario = usuario?.uid ?? 'desconocido';

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

    final registro = {
      'studentId': widget.alumno['docId'],
      'fecha': DateTime.now(),
      'color': colorSeleccionado,
      'descripcion': listaConductas.map((c) => '• $c').join('\n'),
      'comentario': comentarioController.text.trim(),
      'grado': widget.alumno['grado'],
      'seccion': widget.alumno['seccion'],
      'nivel': widget.alumno['nivel'] ?? 'Escolar Básica',
      'userId': uidUsuario,
    };

    await FirebaseFirestore.instance.collection('conductas').add(registro);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Registro guardado de ${widget.alumno['nombre']} ${widget.alumno['apellido']}',
        ),
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildColorCircle(String colorName) {
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
      onTap: () => setState(() => colorSeleccionado = colorName),
      child: CircleAvatar(
        backgroundColor: color,
        radius: 15,
        child: colorSeleccionado == colorName
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar conducta - ${widget.alumno['nombre']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Clasificación',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildColorCircle('verde'),
                  const SizedBox(width: 10),
                  _buildColorCircle('amarillo'),
                  const SizedBox(width: 10),
                  _buildColorCircle('rojo'),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Descripción del suceso',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...conductasFrecuentes.map(
                (c) => CheckboxListTile(
                  title: Text(c),
                  value: conductasSeleccionadas[c],
                  onChanged: (v) =>
                      setState(() => conductasSeleccionadas[c] = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              CheckboxListTile(
                title: const Text('Otros'),
                value: otrosSeleccionado,
                onChanged: (v) {
                  setState(() {
                    otrosSeleccionado = v ?? false;
                    if (!otrosSeleccionado) otrosController.clear();
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (otrosSeleccionado)
                TextFormField(
                  controller: otrosController,
                  decoration: const InputDecoration(
                    labelText: 'Describa la conducta',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: comentarioController,
                decoration: const InputDecoration(
                  labelText: 'Sugerencias / Reflexión',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: registrarConducta,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
