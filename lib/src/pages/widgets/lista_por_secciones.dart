/*import 'package:flutter/material.dart';

class ListaPorSecciones extends StatelessWidget {
  final Map<String, Map<String, List>> datos;
  final Function mostrarDialogoClasificacion;

  const ListaPorSecciones({
    super.key,
    required this.datos,
    required this.mostrarDialogoClasificacion,
  });

  String capitalizarCadaPalabra(String texto) {
    return texto
        .split(' ')
        .map(
          (palabra) => palabra.isEmpty
              ? palabra
              : palabra[0].toUpperCase() + palabra.substring(1),
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 10),
      children: datos.entries.map((gradoEntry) {
        final grado = gradoEntry.key;
        final secciones = gradoEntry.value;

        return ExpansionTile(
          title: Text('$grado° Curso'),
          children: secciones.entries.map((seccionEntry) {
            final seccion = seccionEntry.key;
            final alumnos = seccionEntry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título fijo de sección con capitalización
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Sección ${capitalizarCadaPalabra(seccion)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Encabezado
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: const [
                          SizedBox(
                            width: 30,
                            child: Center(
                              child: Text(
                                'Nro',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            width: 250,
                            child: Text(
                              'Nombre y Apellido',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Lista de alumnos
                ...alumnos.map((alumno) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade400,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                child: Center(
                                  child: Text(
                                    alumno['numero_lista'].toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.grey.shade400,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                              SizedBox(
                                width: 250,
                                child: GestureDetector(
                                  onTap: () =>
                                      mostrarDialogoClasificacion(alumno),
                                  child: Text(
                                    '${alumno['nombre']} ${alumno['apellido']}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
*/
