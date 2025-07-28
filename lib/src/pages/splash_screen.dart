import 'package:flutter/material.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //espera 4 segundo para navegar a Home screen future palabra reservada de dart con su atriburo espera
    //con una duracion de 4 segundo duration palabra reservada con su propiedad tiempo y luego corre la funcion vacia
    //con el codigo dentro luedo de los 4 segundos
    Future.delayed(const Duration(seconds: 4), () {
      //luego de los 4 segundos aqui se empuja la pantalla splash y se elimina de la navegacion y el usuari llega a home screen
      //Tipo esta es una estructura por defecto o estandar de flutter para la funcion de nuelo de que se empuje la pantalla y esas cosas
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        //aqui dice la app que la ruta ya no existe
        (route) => false,
      );
    });
  }

  //Ahora construyo la pantalla son una funcion para hacer lo que se va a mostrar en pantalla y dentro
  //de la clase Splash screen todavia
  @override
  Widget build(BuildContext context) {
    // Scaffold es una estructura básica de una pantalla en Flutter, como en HTML
    return Scaffold(
      // Color de fondo
      backgroundColor: Color.fromARGB(255, 168, 21, 21),
      // En este caso solo haré el cuerpo sin título ni nada
      body: Center(
        // Organizo los elementos de un hijo en forma vertical con Column
        child: Column(
          // Centra el contenido verticalmente
          mainAxisAlignment: MainAxisAlignment.center,
          // Hijos de la columna
          children: const [
            // Muestra la imagen de la carpeta assets/book.png
            Image(
              image: AssetImage("assets/book.png"),
              // Ajusto el tamaño (ancho y altura) de la imagen
              width: 250,
              height: 250,
            ),
            // Espacio vertical en pixeles para separar la imagen del texto
            SizedBox(height: 0),
          ],
        ),
      ),
    );
  }
}
