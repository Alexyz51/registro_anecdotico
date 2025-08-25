/*import 'package:flutter/material.dart';
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
      'grado': widget.alumno['grado'],
      'seccion': widget.alumno['seccion'],
      'nivel': widget.alumno['nivel'] ?? 'escolar basica',
      'registrado_por':
          '${usuarioActual['nombre']} ${usuarioActual['apellido']} ${usuarioActual['rolReal']}',
      'registradoPor': usuarioActual['rolReal'],
      'userId': uidUsuario,
    };

    await FirebaseFirestore.instance.collection('conductas').add(registro);

    // Mensaje y regresar a la pantalla anterior
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Registro de ${widget.alumno['nombre']} ${widget.alumno['apellido']} ha sido guardado con éxito',
        ),
      ),
    );

    Navigator.pop(context); // Vuelve a la pantalla anterior
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
        radius: 16,
        child: colorSeleccionado == colorName
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color cremita = Color.fromARGB(248, 252, 230, 230);
    return Scaffold(
      backgroundColor: cremita,
      appBar: AppBar(
        backgroundColor: cremita,
        title: Text('Registrar Conducta', style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.alumno['nombre']} ${widget.alumno['apellido']} (${widget.alumno['grado']}° Grado - Seccion ${widget.alumno['seccion'].toUpperCase()})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
                'Descripción del suceso:',
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
                  contentPadding: EdgeInsets.zero,
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
                contentPadding: EdgeInsets.zero,
              ),
              if (otrosSeleccionado)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: otrosController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Describa la conducta',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (otrosSeleccionado &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Debe describir la conducta';
                      }
                      return null;
                    },
                  ),
                ),
              TextFormField(
                controller: comentarioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Sugerencias / Reflexión',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingrese sugerencia o reflexión';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: registrarConducta,
                    child: const Text('Guardar'),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
