/*import 'package:flutter/material.dart';

class FilaAlumno extends StatelessWidget {
  final Map alumno;
  final VoidCallback onTap;

  const FilaAlumno({super.key, required this.alumno, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade400, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                SizedBox(
                  width: 250,
                  child: GestureDetector(
                    onTap: onTap,
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
  }
}
*/
