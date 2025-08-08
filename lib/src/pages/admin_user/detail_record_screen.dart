import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailRecordScreen extends StatelessWidget {
  final List registros;
  final String nombreAlumno;

  const DetailRecordScreen({
    Key? key,
    required this.registros,
    required this.nombreAlumno,
  }) : super(key: key);

  Color _colorPorNombre(String? color) {
    switch (color) {
      case 'verde':
        return Colors.green;
      case 'amarillo':
        return Colors.amber;
      case 'rojo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registros de $nombreAlumno')),
      body: registros.isEmpty
          ? const Center(child: Text('No hay registros para mostrar'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: registros.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final reg = registros[index];
                final fecha = reg['fecha'] != null
                    ? (reg['fecha'] as Timestamp).toDate()
                    : null;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _colorPorNombre(reg['color']),
                    radius: 16,
                  ),
                  title: Text(reg['descripcion'] ?? 'Sin descripción'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reg['comentario'] != null &&
                          reg['comentario'].toString().isNotEmpty)
                        Text('Comentario: ${reg['comentario']}'),
                      if (fecha != null) Text('Fecha: ${fecha.toLocal()}'),
                      if (reg['registrado_por'] != null)
                        Text('Registrado por: ${reg['registrado_por']}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
