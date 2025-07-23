import 'package:flutter/material.dart';

class BreadcrumbBar extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const BreadcrumbBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items.map((item) {
        final isFirst = item == items.first;
        final isLast = item == items.last;

        // Si no es el último, puede ser clickeable
        final isClickable = !isLast;

        // Color: gris para el primero y último, azul para el resto
        final color = (isFirst || isLast) ? Colors.grey : Colors.blue;

        // Subrayado: solo si no es primero ni último
        final decoration = (!isFirst && !isLast)
            ? TextDecoration.underline
            : TextDecoration.none;

        return Row(
          children: [
            GestureDetector(
              onTap: isClickable ? item.onTap : null,
              child: Text(
                item.label,
                style: TextStyle(color: color, decoration: decoration),
              ),
            ),
            if (!isLast)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.chevron_right, size: 16),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  BreadcrumbItem({required this.label, this.onTap});
}
