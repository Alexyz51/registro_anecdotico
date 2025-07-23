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
      backgroundColor: Colors.white,
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
              width: 150,
              height: 150,
            ),
            // Espacio vertical en pixeles para separar la imagen del texto
            SizedBox(height: 20),

            // Texto que es el nombre de la app
            Text(
              "Registro Anecdótico",
              //Defino como se ve el texto
              style: TextStyle(
                fontSize: 24, //tamaño del texto
                fontWeight: FontWeight.bold, //Negrita
                color: Color.fromARGB(
                  255,
                  175,
                  183,
                  197,
                ), // Color igual al ícono
              ),
              textAlign: TextAlign.center, //centra el texto bueno si lgmt
            ),

            // Otro espacio
            SizedBox(height: 30),

            // Indicador de carga (loader circular) que esta en material.dart offical de flutter o sea es por defecto de flutter
            CircularProgressIndicator(
              //defino el color
              color: Color.fromARGB(255, 175, 183, 197),
            ),
          ],
        ),
      ),
    );
  }
}
