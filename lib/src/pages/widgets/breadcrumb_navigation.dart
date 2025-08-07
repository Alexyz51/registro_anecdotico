import 'package:flutter/material.dart';

//creo un widget con una barrita de navegacion tipo ruta
class BreadcrumbBar extends StatelessWidget {
  final List<BreadcrumbItem>
  items; //Esta es una lista de los items que vas a mostrar en la barrita

  const BreadcrumbBar({
    super.key,
    required this.items,
  }); //Paso los items obligatoriamente

  @override
  Widget build(BuildContext context) {
    //La parte visual empieza aqui
    return Row(
      //coloca los elemetos en una fila
      children: items.map((item) {
        //para recorrer el mapaflutter run

        final esUltimo =
            item == items.last; //es verdadero si es el ultimo de la lista

        // el último no puede ser clickeable
        final esClikeable = !esUltimo;

        // Color: gris para el primero y último, azul claro para el resto
        final color = Color.fromARGB(226, 201, 183, 171);

        //Aqui va la parte visual
        return Row(
          //se ve el recorrido
          children: [
            GestureDetector(
              //Detecta el toque
              onTap: esClikeable
                  ? item.onTap
                  : null, //si se puede hace click llama a la funcion onTap
              child: Text(
                item.recorrido, //muestra el texto recorrido
                style: TextStyle(color: color),
              ),
            ),
            //Ahora esto agrega una flechita > si no es el ultimo en frete de cada palabra recorrida
            if (!esUltimo)
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

//la clase BreadcrumbItem
class BreadcrumbItem {
  final String recorrido; //es la cadena de Texto que representa el recorrido
  final VoidCallback? onTap; //permite la navegacion si es clickeable

  BreadcrumbItem({
    required this.recorrido,
    this.onTap,
  }); //BreadcrumbItem es la clase que requiere del recorrido para hacer onTap
}
