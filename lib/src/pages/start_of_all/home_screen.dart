import 'package:flutter/material.dart';

//esta pantalla es de estado no mutable porque espero que nada cambie solo se muestra yo que
// ya esta definido
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  //Empiezo a construir la interfaz grafica
  @override
  Widget build(BuildContext context) {
    // Defino el color personalizado que usaremos en textos y botones
    const azulGrisClaro = Color.fromARGB(255, 175, 183, 197);

    return Scaffold(
      // Color de fondo gris claro para toda la pantalla
      backgroundColor: const Color(0xFFEFEFEF),

      // El cuerpo de la pantalla centrado
      body: Center(
        // Permito que el contenido se desplace si la pantalla es pequeña (scroll vertical)
        child: SingleChildScrollView(
          // Espacio horizontal de 24 pixeles a ambos lados para que no quede pegado a los bordes
          padding: const EdgeInsets.symmetric(horizontal: 24),

          // Caja que limita el ancho máximo del contenido para que no quede demasiado ancho en pantallas grandes
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 350, // ancho máximo de la tarjeta
            ),

            // Aquí empieza la card con estilo
            child: Card(
              // Bordes redondeados
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              // Sombra debajo de la tarjeta para darle relieve
              elevation: 8,

              // Espacio interno (padding) dentro de la tarjeta para separar el contenido de los bordes
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24, // 24 pixeles a izquierda y derecha
                  vertical: 32, // 32 pixeles arriba y abajo
                ),

                // Columna para organizar los widgets verticalmente
                child: Column(
                  // Ocupa el espacio justo necesario en vertical
                  mainAxisSize: MainAxisSize.min,

                  // Hijos dentro de la columna
                  children: [
                    // Texto "Bienvenido" con estilo personalizado
                    const Text(
                      "Bienvenido",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold, //negrita
                        color: azulGrisClaro, // color definido arriba
                      ),
                    ),

                    // Espacio vertical de 40 pixeles para separar texto y de lo que sigue
                    const SizedBox(height: 40),

                    // Botón principal (ElevatedButton) para iniciar sesión
                    ElevatedButton(
                      onPressed: () {
                        // Navega a la pantalla de login usando rutas nombrada en main
                        Navigator.pushNamed(context, 'login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            azulGrisClaro, // color de fondo del botón
                        minimumSize: const Size.fromHeight(
                          48,
                        ), // alto mínimo 48 pixeles
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // bordes redondeados del botón
                        ),
                      ),
                      // Texto dentro del botón que era en un child xd
                      child: const Text("Iniciar sesión"),
                    ),

                    // Espacio vertical de 20 pixeles entre los botones otra vez
                    const SizedBox(height: 20),

                    // Botón secundario (OutlinedButton) para registrarse
                    OutlinedButton(
                      onPressed: () {
                        // Navega a la pantalla de registro usando rutas nombrada en main.dart
                        Navigator.pushNamed(context, 'register');
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          48,
                        ), // alto mínimo 48 pixeles
                        side: const BorderSide(
                          color: azulGrisClaro,
                        ), // borde del botón con color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // bordes redondeados
                        ),
                      ),
                      // Texto dentro del botón con color azul gris claro
                      child: const Text(
                        "Registrarse",
                        style: TextStyle(color: azulGrisClaro),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
