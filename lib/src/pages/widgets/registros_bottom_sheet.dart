import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Función para mostrar los registros de un alumno en un BottomSheet
/// [context] -> contexto de la app
/// [registros] -> lista de registros de conducta del alumno
/// [nombreAlumno] -> nombre del alumno para mostrar en el título
void mostrarRegistrosBottomSheet(
  BuildContext context,
  List registros,
  String nombreAlumno,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled:
        true, // permite que el BottomSheet use más espacio vertical
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false, // no ocupa toda la pantalla al arrastrar
        maxChildSize: 0.8, // tamaño máximo de la hoja (80% de la pantalla)
        minChildSize: 0.3, // tamaño mínimo al colapsar (30%)
        initialChildSize: 0.5, // tamaño inicial (50%)
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Título
                Text(
                  'Registros de $nombreAlumno',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Lista de registros con scroll
                Expanded(
                  child: ListView.separated(
                    controller:
                        scrollController, // controla el scroll del sheet
                    itemCount: registros.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final reg = registros[index];

                      // Convertir fecha de Timestamp a DateTime
                      final fecha = reg['fecha'] != null
                          ? (reg['fecha'] as Timestamp).toDate()
                          : null;

                      // Definir color según el registro
                      Color colorRegistro;
                      switch (reg['color']) {
                        case 'verde':
                          colorRegistro = Colors.green;
                          break;
                        case 'amarillo':
                          colorRegistro = Colors.amber;
                          break;
                        case 'rojo':
                          colorRegistro = Colors.red;
                          break;
                        default:
                          colorRegistro = Colors.grey;
                      }

                      // Cada registro se muestra en un ListTile
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorRegistro,
                          radius: 14,
                        ),
                        title: Text(reg['descripcion'] ?? 'Sin descripción'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (reg['comentario'] != null &&
                                reg['comentario'].toString().isNotEmpty)
                              Text('Comentario: ${reg['comentario']}'),
                            if (fecha != null)
                              Text('Fecha: ${fecha.toLocal()}'),
                            if (reg['registrado_por'] != null)
                              Text('Registrado por: ${reg['registrado_por']}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Botón siempre visible para cerrar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
