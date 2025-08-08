import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void mostrarRegistrosBottomSheet(
  BuildContext context,
  List registros,
  String nombreAlumno,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        initialChildSize: 0.5,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Registros de $nombreAlumno',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: registros.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final reg = registros[index];
                      final fecha = reg['fecha'] != null
                          ? (reg['fecha'] as Timestamp).toDate()
                          : null;

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
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
