import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';

class EditListScreen extends StatefulWidget {
  const EditListScreen({super.key});

  @override
  State<EditListScreen> createState() => _EditListScreenState();
}

class _EditListScreenState extends State<EditListScreen> {
  // Estructura para guardar alumnos organizados: Nivel -> Grado -> Sección -> Lista de alumnos
  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> data = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carga datos desde Firestore y organiza en el mapa 'data'
  Future<void> _loadData() async {
    setState(() {
      loading = true;
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .get();

    final tempData =
        <String, Map<String, Map<String, List<Map<String, dynamic>>>>>{};

    for (var doc in snapshot.docs) {
      final d = doc.data();
      final nivel = d['nivel'] ?? 'Sin nivel';
      final grado = d['grado'] ?? 'Sin grado';
      final seccion = d['seccion'] ?? 'Sin sección';

      tempData.putIfAbsent(nivel, () => {});
      tempData[nivel]!.putIfAbsent(grado, () => {});
      tempData[nivel]![grado]!.putIfAbsent(seccion, () => []);

      Map<String, dynamic> alumnoConId = Map<String, dynamic>.from(d);
      alumnoConId['docId'] = doc.id;

      tempData[nivel]![grado]![seccion]!.add(alumnoConId);
    }

    // Ordenar niveles, grados y secciones
    tempData.forEach((nivel, grados) {
      var gradosList = grados.keys.toList();
      if (nivel == 'Nivel Medio') {
        gradosList.sort((a, b) {
          int? aNum = int.tryParse(a);
          int? bNum = int.tryParse(b);
          if (aNum != null && bNum != null) {
            return aNum.compareTo(bNum);
          }
          return a.compareTo(b);
        });
      } else {
        gradosList.sort();
      }

      final gradosOrdenadosMap =
          <String, Map<String, List<Map<String, dynamic>>>>{};
      for (var grado in gradosList) {
        final secciones = grados[grado]!;

        List<String> seccionesOrdenadas = secciones.keys.toList();
        if (nivel == 'Nivel Medio') {
          seccionesOrdenadas.sort((a, b) {
            if (a == 'A') return -1;
            if (b == 'A') return 1;
            return a.compareTo(b);
          });
        } else {
          seccionesOrdenadas.sort();
        }

        final seccionesOrdenadasMap = <String, List<Map<String, dynamic>>>{};
        for (var sec in seccionesOrdenadas) {
          final alumnos = secciones[sec]!;

          // Ordenar alumnos por número de lista
          alumnos.sort(
            (a, b) =>
                (a['numero_lista'] as int).compareTo(b['numero_lista'] as int),
          );
          seccionesOrdenadasMap[sec] = alumnos;
        }
        gradosOrdenadosMap[grado] = seccionesOrdenadasMap;
      }
      tempData[nivel] = gradosOrdenadosMap;
    });

    setState(() {
      data = tempData;
      loading = false;
    });
  }

  // Reorganiza los números de lista para un nivel, grado y sección (consecutivos desde 1)
  Future<void> _reorganizarNumeroLista(
    String nivel,
    String grado,
    String seccion,
  ) async {
    final alumnos = data[nivel]?[grado]?[seccion];
    if (alumnos == null) return;

    // Ordenar localmente para asegurar secuencia
    alumnos.sort(
      (a, b) => (a['numero_lista'] as int).compareTo(b['numero_lista'] as int),
    );

    final batch = FirebaseFirestore.instance.batch();

    for (int i = 0; i < alumnos.length; i++) {
      final alumno = alumnos[i];
      final nuevoNumero = i + 1;
      if (alumno['numero_lista'] != nuevoNumero) {
        alumno['numero_lista'] = nuevoNumero;
        final docRef = FirebaseFirestore.instance
            .collection('students')
            .doc(alumno['docId']);
        batch.update(docRef, {'numero_lista': nuevoNumero});
      }
    }

    await batch.commit();

    // Refrescar datos y UI
    await _loadData();
  }

  // Agrega un alumno asignando automáticamente el número de lista al final
  Future<void> _agregarAlumnoAuto({
    required String nombre,
    required String apellido,
    required String grado,
    required String seccion,
    required String nivel,
    required int anio,
  }) async {
    final alumnos = data[nivel]?[grado]?[seccion] ?? [];
    final nuevoNumeroLista = alumnos.length + 1;

    await FirebaseFirestore.instance.collection('students').add({
      'nombre': nombre,
      'apellido': apellido,
      'grado': grado,
      'seccion': seccion,
      'nivel': nivel,
      'numero_lista': nuevoNumeroLista,
      'anio': anio,
    });

    await _loadData();
  }

  // Diálogo para agregar alumno (sin número lista, se asigna automático)
  Future<void> _showAddAlumnoDialog() async {
    final _formKey = GlobalKey<FormState>();
    String nombre = '';
    String apellido = '';
    String grado = '';
    String seccion = '';
    String nivel = '';
    int anio = 0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar alumno'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  onSaved: (v) => nombre = v!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  onSaved: (v) => apellido = v!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Grado'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  onSaved: (v) => grado = v!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Sección'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  onSaved: (v) => seccion = v!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nivel'),
                  validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  onSaved: (v) => nivel = v!.trim(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Año'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (int.tryParse(v) == null) return 'Debe ser un número';
                    return null;
                  },
                  onSaved: (v) => anio = int.parse(v!),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                await _agregarAlumnoAuto(
                  nombre: nombre,
                  apellido: apellido,
                  grado: grado,
                  seccion: seccion,
                  nivel: nivel,
                  anio: anio,
                );

                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Elimina un alumno y reorganiza el número de lista automáticamente
  Future<void> _deleteAlumno(String docId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Seguro quieres eliminar este alumno?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm) {
      final doc = await FirebaseFirestore.instance
          .collection('students')
          .doc(docId)
          .get();
      final alumno = doc.data();
      if (alumno == null) return;

      final nivel = alumno['nivel'] ?? '';
      final grado = alumno['grado'] ?? '';
      final seccion = alumno['seccion'] ?? '';

      await FirebaseFirestore.instance
          .collection('students')
          .doc(docId)
          .delete();

      await _loadData();
      await _reorganizarNumeroLista(nivel, grado, seccion);
    }
  }

  // Borra toda la colección de alumnos
  Future<void> _deleteAllAlumnos() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar borrado total'),
        content: const Text(
          '¿Seguro quieres borrar todos los alumnos? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Borrar todo'),
          ),
        ],
      ),
    );

    if (confirm) {
      final batch = FirebaseFirestore.instance.batch();

      final snapshot = await FirebaseFirestore.instance
          .collection('students')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      await _loadData();
    }
  }

  // Importar CSV (igual que antes, puede llamar _loadData después de importar)
  Future<void> _showImportCsvDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar alumnos desde CSV'),
        content: SizedBox(
          width: double.maxFinite,
          child: CsvImportWidget(
            onImportCompleted: () {
              Navigator.pop(context);
              _loadData();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar lista'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Botones de acción
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Importar CSV'),
                  onPressed: _showImportCsvDialog,
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar alumno'),
                  onPressed: _showAddAlumnoDialog,
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Borrar todo'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: _deleteAllAlumnos,
                ),
              ],
            ),
          ),
          // Lista organizada de alumnos
          Expanded(
            child: ListView(
              children: data.entries.map((nivelEntry) {
                final nivel = nivelEntry.key;
                final grados = nivelEntry.value;

                return ExpansionTile(
                  title: Text(nivel),
                  children: grados.entries.map((gradoEntry) {
                    final grado = gradoEntry.key;
                    final secciones = gradoEntry.value;

                    return ExpansionTile(
                      title: Text(
                        nivel == 'Nivel Medio'
                            ? '$grado curso'
                            : 'Grado: $grado',
                      ),
                      children: secciones.entries.map((seccionEntry) {
                        final seccion = seccionEntry.key;
                        final alumnos = seccionEntry.value;

                        return ExpansionTile(
                          title: Text('Sección: $seccion'),
                          children: alumnos.map((alumno) {
                            return ListTile(
                              title: Text(
                                '${alumno['numero_lista']}  ${alumno['nombre']} ${alumno['apellido']}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteAlumno(alumno['docId']),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para importar CSV
class CsvImportWidget extends StatefulWidget {
  final VoidCallback onImportCompleted;

  const CsvImportWidget({required this.onImportCompleted, super.key});

  @override
  State<CsvImportWidget> createState() => _CsvImportWidgetState();
}

class _CsvImportWidgetState extends State<CsvImportWidget> {
  bool _isLoading = false;
  String? _message;
  int _importedCount = 0;

  Future<void> _pickAndUploadCsv() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _importedCount = 0;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result == null) {
        setState(() {
          _isLoading = false;
          _message = 'No se seleccionó ningún archivo.';
        });
        return;
      }

      final bytes = result.files.single.bytes;
      if (bytes == null) throw 'No se pudieron obtener los datos del archivo.';
      final content = utf8.decode(bytes);

      final fields = const CsvToListConverter(
        fieldDelimiter: ';',
      ).convert(content);

      if (fields.isEmpty) {
        setState(() {
          _isLoading = false;
          _message = 'El archivo está vacío.';
        });
        return;
      }

      int count = 0;
      // Asumiendo que la fila 0 es encabezado
      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length < 7) continue;

        final data = {
          'nombre': row[0].toString(),
          'apellido': row[1].toString(),
          'grado': row[2].toString(),
          'seccion': row[3].toString(),
          'anio': int.tryParse(row[4].toString()) ?? 0,
          'numero_lista': int.tryParse(row[5].toString()) ?? 0,
          'nivel': row[6].toString(),
        };

        await FirebaseFirestore.instance.collection('students').add(data);
        count++;
      }

      setState(() {
        _isLoading = false;
        _importedCount = count;
        _message = 'Se importaron correctamente $count alumnos.';
      });

      widget.onImportCompleted();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error durante la importación: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _pickAndUploadCsv,
          child: const Text('Seleccionar archivo CSV'),
        ),
        const SizedBox(height: 20),
        if (_isLoading) const CircularProgressIndicator(),
        if (_message != null) Text(_message!),
        if (_importedCount > 0) Text('Total importados: $_importedCount'),
      ],
    );
  }
}
