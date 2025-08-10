import 'package:flutter/material.dart';

// Widget barra de navegación tipo breadcrumb
class BreadcrumbBar extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const BreadcrumbBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        final esUltimo = item == items.last;
        final esClickable = !esUltimo;

        // Usa el color personalizado si existe, si no, usa un rojo oscuro por defecto
        final color = item.textoColor ?? const Color(0xFF270202);

        return Row(
          children: [
            GestureDetector(
              onTap: esClickable ? item.onTap : null,
              child: Text(
                item.recorrido,
                style: TextStyle(
                  color: color,
                  decoration: null, // Sin subrayado
                ),
              ),
            ),
            if (!esUltimo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right, size: 16, color: color),
              ),
          ],
        );
      }).toList(),
    );
  }
}

// Clase BreadcrumbItem ahora con parámetro opcional textoColor
class BreadcrumbItem {
  final String recorrido;
  final VoidCallback? onTap;
  final Color? textoColor; // Parámetro para el color del texto

  BreadcrumbItem({required this.recorrido, this.onTap, this.textoColor});
}
