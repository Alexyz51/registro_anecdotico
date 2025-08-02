import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EscolarBasicaScreen extends StatefulWidget {
  const EscolarBasicaScreen({super.key});

  @override
  State<EscolarBasicaScreen> createState() => _EscolarBasicaScreenState();
}

class _EscolarBasicaScreenState extends State<EscolarBasicaScreen> {
  bool estaCargando = true;

  // Estructura para guardar los datos organizados
  Map<String, Map<String, List<Map<String, dynamic>>>> datos = {};

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    setState(() {
      estaCargando = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('nivel', isEqualTo: 'escolar basica')
        .get();

    final datosTemp = <String, Map<String, List<Map<String, dynamic>>>>{};

    for (var doc in snapshot.docs) {
      final d = doc.data();
      final grado = d['grado'] ?? 'Sin grado';
      final seccion = d['seccion'] ?? 'Sin sección';

      datosTemp.putIfAbsent(grado, () => {});
      datosTemp[grado]!.putIfAbsent(seccion, () => []);

      Map<String, dynamic> alumnoConId = Map<String, dynamic>.from(d);
      alumnoConId['docId'] = doc.id;

      datosTemp[grado]![seccion]!.add(alumnoConId);
    }

    // Ordenar grados y secciones
    final gradosOrdenados = datosTemp.keys.toList()..sort();
    final datosOrdenados = <String, Map<String, List<Map<String, dynamic>>>>{};

    for (var grado in gradosOrdenados) {
      final secciones = datosTemp[grado]!;
      final seccionesOrdenadas = secciones.keys.toList()..sort();

      final seccionesOrdenadasMap = <String, List<Map<String, dynamic>>>{};
      for (var sec in seccionesOrdenadas) {
        final alumnos = secciones[sec]!;

        alumnos.sort(
          (a, b) =>
              (a['numero_lista'] as int).compareTo(b['numero_lista'] as int),
        );

        seccionesOrdenadasMap[sec] = alumnos;
      }
      datosOrdenados[grado] = seccionesOrdenadasMap;
    }

    setState(() {
      datos = datosOrdenados;
      estaCargando = false;
    });
  }

  // Guardar registro de conducta
  Future<void> registrarConducta({
    required String color,
    required String comentario,
    required Map<String, dynamic> alumno,
  }) async {
    final registro = {
      'studentId': alumno['docId'],
      'fecha': DateTime.now(),
      'color': color,
      'comentario': comentario,
      'grado': alumno['grado'],
      'seccion': alumno['seccion'],
      'nivel': alumno['nivel'],
      'nombreUsuario':
          'Cargo Nombre Apellido', // Aquí deberías usar el usuario autenticado
    };

    await FirebaseFirestore.instance.collection('records').add(registro);
  }

  Future<void> mostrarDialogoRegistro(
    Map<String, dynamic> alumno,
    String color,
  ) async {
    final _formKey = GlobalKey<FormState>();
    String comentario = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Registrar conducta - ${color[0].toUpperCase()}${color.substring(1)}',
          ),
          content: Form(
            key: _formKey,
            child: TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comentario',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El comentario es obligatorio';
                }
                return null;
              },
              onSaved: (value) {
                comentario = value!.trim();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  await registrarConducta(
                    color: color,
                    comentario: comentario,
                    alumno: alumno,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Registro guardado para ${alumno['nombre']}',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Color colorDeCadena(String color) {
    switch (color.toLowerCase()) {
      case 'rojo':
        return Colors.red;
      case 'amarillo':
        return Colors.amber;
      case 'verde':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (estaCargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Escolar Básica')),
      body: ListView(
        children: datos.entries.map((gradoEntry) {
          final grado = gradoEntry.key;
          final secciones = gradoEntry.value;

          return ExpansionTile(
            title: Text('Grado: $grado'),
            children: secciones.entries.map((seccionEntry) {
              final seccion = seccionEntry.key;
              final alumnos = seccionEntry.value;

              return ExpansionTile(
                title: Text(
                  'Sección: ${seccion[0].toUpperCase()}${seccion.substring(1)}',
                ),
                children: alumnos.map((alumno) {
                  return ListTile(
                    title: Text(
                      '${alumno['numero_lista']}. ${alumno['nombre']} ${alumno['apellido']}',
                    ),
                    trailing: Wrap(
                      spacing: 6,
                      children: [
                        IconButton(
                          icon: Icon(Icons.circle, color: Colors.green),
                          onPressed: () =>
                              mostrarDialogoRegistro(alumno, 'verde'),
                          tooltip: 'Marcar conducta verde',
                        ),
                        IconButton(
                          icon: Icon(Icons.circle, color: Colors.amber),
                          onPressed: () =>
                              mostrarDialogoRegistro(alumno, 'amarillo'),
                          tooltip: 'Marcar conducta amarillo',
                        ),
                        IconButton(
                          icon: Icon(Icons.circle, color: Colors.red),
                          onPressed: () =>
                              mostrarDialogoRegistro(alumno, 'rojo'),
                          tooltip: 'Marcar conducta rojo',
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
