import 'dart:convert'; //Para convertir bytes en texto (utf8.decode)
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Para permitir al usuario seleccionar archivos desde su dispositivo
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart'; //Para convertir archivos .csv en listas legibles por el programa
import 'package:registro_anecdotico/src/pages/widgets/breadcrumb_navigation.dart';
import 'package:diacritic/diacritic.dart'; //Para quitar acentos y cosas de ortogrfia correcta

// Definicion de las varibles permitidas
final nivelesPermitidos = ['escolar basica', 'nivel medio'];
final gradosEscolarBasica = ['7', '8', '9']; // Séptimo, octavo, noveno
final gradosNivelMedio = ['1', '2', '3']; // Primero, segundo, tercero
final seccionesEscolarBasica = ['a', 'b'];
final seccionesNivelMedio = ['ciencias basicas', 'informatica'];

// Función para normalizar texto normalizar con el paquete de diacritic
String normalizar(String s) {
  return removeDiacritics(s.trim().toLowerCase());
}

class EditListScreen extends StatefulWidget {
  const EditListScreen({super.key});

  @override
  State<EditListScreen> createState() => _EditListScreenState();
}

class _EditListScreenState extends State<EditListScreen> {
  //Estructura tipo arbol donde seguardaran los datos
  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> datos = {};
  bool cargando = true; // variable para indicar la carga de datos

  @override
  void initState() {
    //estado inicial de la pantalla
    super.initState();
    _cargaDeDatos(); //en el estado inicial empieza la carga de datos para llamar a la base de datos e iniciar
  }

  Future<void> _cargaDeDatos() async {
    //metodo de carga de datos
    setState(() {
      cargando = true; //empieza a cargar
    });

    // Obtener copiainstantánea (snapshot) o fotos de todos los documentos de 'students'
    final copiaInstantanea = await FirebaseFirestore.instance
        .collection('students')
        .get();

    //Datos temporales obtenidos listos para ordenar
    final datosTemp =
        <String, Map<String, Map<String, List<Map<String, dynamic>>>>>{};

    for (var doc in copiaInstantanea.docs) {
      //para cada documento una foto
      final d = doc.data(); //toda la info del documento
      final nivel =
          d['nivel'] ?? 'Sin nivel'; //se obtiene el nivel sino sin nivel
      final grado =
          d['grado'] ?? 'Sin grado'; //se obtiene el grado sino sin grado
      final seccion =
          d['seccion'] ??
          'Sin sección'; //se obtiene la seccion sino sin seccion

      // Estructura: nivel → grado → sección → lista de alumnos
      datosTemp.putIfAbsent(nivel, () => {});
      datosTemp[nivel]!.putIfAbsent(grado, () => {});
      datosTemp[nivel]![grado]!.putIfAbsent(
        seccion,
        () => [],
      ); //crea un lugar para los datos del alumno

      // Copiar datos del alumno y agregar ID del documento para facilitar borrar
      Map<String, dynamic> alumnoConId = Map<String, dynamic>.from(d);
      alumnoConId['docId'] = doc.id;

      // Añade al alumno a la lista correspondiente
      datosTemp[nivel]![grado]![seccion]!.add(alumnoConId);
    }

    // Ordenar niveles, grados y secciones para que la UI tenga un orden lógico
    datosTemp.forEach((nivel, grados) {
      var gradosList = grados.keys.toList();
      if (nivel == 'nivel medio') {
        gradosList.sort((a, b) {
          // Ordena grados numéricamente si es nivel medio
          int? aNum = int.tryParse(a);
          int? bNum = int.tryParse(b);
          if (aNum != null && bNum != null) {
            return aNum.compareTo(bNum);
          }
          return a.compareTo(b);
        });
      } else {
        gradosList.sort(); // Alfabético para otros niveles
      }

      final gradosOrdenadosMap =
          <String, Map<String, List<Map<String, dynamic>>>>{};
      for (var grado in gradosList) {
        final secciones = grados[grado]!;

        List<String> seccionesOrdenadas = secciones.keys.toList();
        if (nivel == 'nivel medio') {
          seccionesOrdenadas.sort((a, b) {
            if (a == 'a') return -1;
            if (b == 'a') return 1;
            return a.compareTo(b);
          });
        } else {
          seccionesOrdenadas.sort();
        }

        final seccionesOrdenadasMap = <String, List<Map<String, dynamic>>>{};
        for (var sec in seccionesOrdenadas) {
          final alumnos = secciones[sec]!;

          alumnos.sort(
            (a, b) =>
                (a['numero_lista'] as int).compareTo(b['numero_lista'] as int),
          );
          seccionesOrdenadasMap[sec] = alumnos;
        }
        gradosOrdenadosMap[grado] = seccionesOrdenadasMap;
      }
      datosTemp[nivel] = gradosOrdenadosMap;
    });

    setState(() {
      datos = datosTemp;
      cargando = false;
    });
  }

  Future<void> _reorganizarNumeroLista(
    String nivel,
    String grado,
    String seccion,
  ) async {
    final alumnos = datos[nivel]?[grado]?[seccion];
    if (alumnos == null) return;

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

    await _cargaDeDatos();
  }

  Future<void> _agregarAlumnoAuto({
    required String nombre,
    required String apellido,
    required String grado,
    required String seccion,
    required String nivel,
    required int anio,
  }) async {
    final alumnos = datos[nivel]?[grado]?[seccion] ?? [];
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

    await _cargaDeDatos();
  }

  Future<void> _showAddAlumnoDialog() async {
    final _formKey = GlobalKey<FormState>();
    String nombre = '';
    String apellido = '';
    String? nivel;
    String? grado;
    String? seccion;
    int? anio;

    List<String> gradosDisponibles = [];
    List<String> seccionesDisponibles = [];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Actualizar listas según nivel seleccionado
            if (nivel == 'escolar basica') {
              gradosDisponibles = gradosEscolarBasica;
              seccionesDisponibles = seccionesEscolarBasica;
            } else if (nivel == 'nivel medio') {
              gradosDisponibles = gradosNivelMedio;
              seccionesDisponibles = seccionesNivelMedio;
            } else {
              gradosDisponibles = [];
              seccionesDisponibles = [];
            }

            return AlertDialog(
              title: const Text('Agregar alumno'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requerido' : null,
                        onSaved: (v) => nombre = v!.trim(),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Apellido',
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Requerido' : null,
                        onSaved: (v) => apellido = v!.trim(),
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Nivel'),
                        items: nivelesPermitidos
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e[0].toUpperCase() + e.substring(1),
                                ), // Capitalizar
                              ),
                            )
                            .toList(),
                        value: nivel,
                        onChanged: (val) {
                          setStateDialog(() {
                            nivel = val;
                            grado = null;
                            seccion = null;
                          });
                        },
                        validator: (v) => v == null ? 'Requerido' : null,
                        onSaved: (v) => nivel = v,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Grado'),
                        items: gradosDisponibles
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        value: grado,
                        onChanged: (val) {
                          setStateDialog(() {
                            grado = val;
                          });
                        },
                        validator: (v) => v == null ? 'Requerido' : null,
                        onSaved: (v) => grado = v,
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Sección'),
                        items: seccionesDisponibles
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e[0].toUpperCase() + e.substring(1),
                                ),
                              ),
                            )
                            .toList(),
                        value: seccion,
                        onChanged: (val) {
                          setStateDialog(() {
                            seccion = val;
                          });
                        },
                        validator: (v) => v == null ? 'Requerido' : null,
                        onSaved: (v) => seccion = v,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Año'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          if (int.tryParse(v) == null)
                            return 'Debe ser un número';
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

                      // Normalizar para guardar en Firestore
                      final nivelNorm = normalizar(nivel!);
                      final gradoNorm = normalizar(grado!);
                      final seccionNorm = normalizar(seccion!);

                      await _agregarAlumnoAuto(
                        nombre: nombre,
                        apellido: apellido,
                        grado: gradoNorm,
                        seccion: seccionNorm,
                        nivel: nivelNorm,
                        anio: anio!,
                      );

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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

      await _cargaDeDatos();
      await _reorganizarNumeroLista(nivel, grado, seccion);
    }
  }

  Future<void> _borrarTodosLosAlumnos() async {
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

      await _cargaDeDatos();
    }
  }

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
              _cargaDeDatos();
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
    if (cargando) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar lista'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BreadcrumbBar(
            items: [
              BreadcrumbItem(
                recorrido: 'Inicio',
                onTap: () {
                  Navigator.pushNamed(context, '/');
                },
              ),
              BreadcrumbItem(recorrido: 'Editar lista'),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Importar CSV'),
                    onPressed: _showImportCsvDialog,
                  ),
                ),
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar alumno'),
                    onPressed: _showAddAlumnoDialog,
                  ),
                ),
                Flexible(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Borrar todo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _borrarTodosLosAlumnos,
                  ),
                ),
              ],
            ),
          ),
          // En esta seccion se muestra la lista y otras funciones se ejecutan como eliminar etc
          Expanded(
            child: ListView(
              children: datos.entries.map((nivelEntry) {
                final nivel = nivelEntry.key;
                final grados = nivelEntry.value;

                return ExpansionTile(
                  title: Text(nivel[0].toUpperCase() + nivel.substring(1)),
                  children: grados.entries.map((gradoEntry) {
                    final grado = gradoEntry.key;
                    final secciones = gradoEntry.value;

                    return ExpansionTile(
                      title: Text(
                        nivel == 'nivel medio'
                            ? '$grado ° Curso'
                            : 'Grado: $grado',
                      ),
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

// Esta seccion forma parte de importar desde csv que debo cambiar a español
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
      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length < 7) continue;

        final nombre = row[0].toString().trim();
        final apellido = row[1].toString().trim();
        final seccionRaw = row[2].toString();
        final nivelRaw = row[3].toString();
        final gradoRaw = row[4].toString();
        final numeroListaRaw = row[5].toString();
        final anioRaw = row[6].toString();

        final nivel = normalizar(nivelRaw);
        final grado = normalizar(gradoRaw);
        final seccion = normalizar(seccionRaw);
        final numeroLista = int.tryParse(numeroListaRaw) ?? 0;
        final anio = int.tryParse(anioRaw) ?? 0;

        if (!nivelesPermitidos.contains(nivel)) continue;
        if (nivel == 'escolar basica' && !gradosEscolarBasica.contains(grado))
          continue;
        if (nivel == 'nivel medio' && !gradosNivelMedio.contains(grado))
          continue;
        if (nivel == 'escolar basica' &&
            !seccionesEscolarBasica.contains(seccion))
          continue;
        if (nivel == 'nivel medio' && !seccionesNivelMedio.contains(seccion))
          continue;

        final data = {
          'nombre': nombre,
          'apellido': apellido,
          'grado': grado,
          'seccion': seccion,
          'anio': anio,
          'numero_lista': numeroLista,
          'nivel': nivel,
        };

        await FirebaseFirestore.instance.collection('students').add(data);
        count++;
      }

      setState(() {
        _isLoading = false;
        _message = 'Importados $count alumnos.';
        _importedCount = count;
      });

      widget.onImportCompleted();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = 'Error al importar CSV: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading)
          const CircularProgressIndicator()
        else
          ElevatedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Seleccionar archivo CSV'),
            onPressed: _pickAndUploadCsv,
          ),
        if (_message != null) ...[const SizedBox(height: 10), Text(_message!)],
      ],
    );
  }
}
