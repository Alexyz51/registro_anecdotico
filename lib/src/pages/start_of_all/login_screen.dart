import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasenia = TextEditingController();
  bool _cargaDeDatos = false; //declaro la variable apagada

  Future<void> iniciarSesion() async {
    //esta fucion es la que se llama al iniciar sesion
    if (_formKey.currentState!.validate()) {
      //verifica que los campos no estén vacíos, que el correo tenga formato correcto, etc.El¡ me promete que estan completos los campos
      setState(() {
        //setState actualiza la interfaz
        _cargaDeDatos = true;
      });

      final correoFinal = correo.text.trim().toLowerCase();
      final contraseniaFinal = contrasenia.text.trim();

      try {
        //intenta iniciar sesion en direbase auth
        final credenciales = await FirebaseAuth
            .instance //revisamos en fire auth que el correo y contraseña coindan con los ingresados
            .signInWithEmailAndPassword(
              email: correoFinal,
              password: contraseniaFinal,
            );

        final uid = credenciales
            .user!
            .uid; //significa que los datos ya han sido registrados

        final consulta = await FirebaseFirestore
            .instance //intenta  los datos osea una vez otenido el ID de documento accede al correo
            .collection('users')
            .where('correo', isEqualTo: correoFinal)
            .limit(1) //solo un documento
            .get();

        if (consulta.docs.isEmpty) {
          //pero si la consulta es empty osea no hay documento desde un principio
          _mostrarDialogo("Error", "No se encontró información del usuario.");
          return;
        }

        final datosUsuario = consulta.docs.first.data(); //extremos los datos
        final rol =
            datosUsuario['rol']; //estraemos rol y lo usamos en una estructura si;si no;entonces para redirigir
        // al usuario de acuerdo a su rol a su pantalla
        if (!mounted) return;

        if (rol == 'usuario') {
          Navigator.pushReplacementNamed(context, 'user_home');
        } else if (rol == 'administrador') {
          Navigator.pushReplacementNamed(context, 'admin_home');
        } else {
          _mostrarDialogo("Error", "Rol no reconocido: $rol");
        }
      } catch (e) {
        //si se captura un erro de antes al iniciar sesion en rirebase auth muestra
        _mostrarDialogo("Error", "Correo o contraseña incorrectos.");
      } finally {
        setState(() {
          _cargaDeDatos =
              false; //una vez que todo el proceso termino carga de datos se apaga
        });
      }
    }
  }

  void _mostrarDialogo(String titulo, String mensaje) {
    //muestra un cuadro de dialogo popup con un titulo error y el mensaje que puse en el if,else
    showDialog(
      //funcion para mostrar un cuadro de dialogo emergente esta funvion se puso el el else
      /*if (consulta.docs.isEmpty) {
      _mostrarDialogo("Error", "No se encontró información del usuario.");
      return;
      }
    */
      context: context, //en el context de la pantalla
      builder: (_) => AlertDialog(
        //construye el cuadro
        title: Text(titulo), //el primer string
        content: Text(mensaje), //el segundo string
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.pop(context), //vuelve al contexto
          ),
        ],
      ),
    );
  }

  // se empieza a construir la interfaz grafica es una estrutura basica de flutter que devuelve un widget que renderiza
  @override
  Widget build(BuildContext context) {
    String hexColor = '#8e0b13';
    // Convierte la cadena hexadecimal a un entero, omitiendo el '#'
    int colorValue = int.parse(hexColor.substring(1), radix: 16);

    // Crea un objeto Color con el valor entero
    Color miColor = Color(
      colorValue | 0xFF000000,
    ); // Agrega el canal alfa (FF para opaco)
    return Scaffold(
      //color de fondo
      backgroundColor: miColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
        ), //boton para ir a inicio o home_screen
      ),
      body: Center(
        //el contenido del cuerpo se centra
        child: SingleChildScrollView(
          //SingleChildScrollView: Permite desplazarse verticalmente si el contenido es más alto que la pantalla.
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
          ), //24 pixeles de lada a lado
          child: Column(
            //para que los hijos se muestren en forma vertical
            mainAxisSize:
                MainAxisSize.min, //la columna ocupara solo lo necesario
            children: [
              Image.asset('assets/book.png', height: 100),
              //imagen que viene antes de los campos
              const SizedBox(height: 16), // distancia de 16 pixeles
              Text(
                '¡BIENVENIDO!',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 350,
                ), //limita el ancho en 350 px
                child: Card(
                  // crea la tarjeta ocard
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      //añadee un espacio interior dentro de la tarjeta
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Form(
                      //se agrupan los textos en text form fild
                      key:
                          _formKey, // La clave de formulario para referirnos a ellos en conjunto
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Iniciar sesión', // titulo
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: const Color.fromARGB(255, 39, 2, 2),
                            ),
                          ),
                          const SizedBox(height: 20), //espacio
                          TextFormField(
                            controller:
                                correo, // controller es un propiedad del widget textformfield y
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white, // fondo blanco
                              labelText: "Correo electrónico",
                              labelStyle: TextStyle(
                                color:
                                    Colors.grey[400], // etiqueta gris clarito
                              ),
                              iconColor: const Color.fromARGB(255, 39, 2, 2),

                              // Borde normal (no enfocado)
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .grey[400]!, // un poquito más oscuro que antes
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(
                                  4,
                                ), // radio consistente
                              ),

                              // Borde enfocado
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .grey[500]!, // borde más oscuro cuando se toca
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  4,
                                ), // mismo radio
                              ),

                              // Borde de error
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors
                                  .black87, // texto ingresado negro legible
                            ),

                            validator: (valor) {
                              // esta propidad llama a formKey.currentState!.validate() y verifica eñ valor u con las propiedade que tiene confiamos que no esta vacio
                              if (valor == null || valor.isEmpty) {
                                // sino escribio nada en el campo entonces esta vacio
                                return 'Ingresa tu correo'; //entonces ingrese su correo
                              }
                              //si paso lo anterio debe cumplir con los requisitos para ser un correo
                              final regex = RegExp(
                                //regex es una expresion triangular para verificar el formato del correo
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              return regex.hasMatch(
                                    valor,
                                  ) // preguntamos si lo ingresado coinside con la expresion retangular
                                  ? null // si no muestra erro si pasa
                                  : 'Correo no válido'; // sino muestra
                            },
                          ),
                          const SizedBox(height: 16), //espacio
                          TextFormField(
                            controller:
                                contrasenia, // Controla el texto que el usuario ingresa (la contraseña)
                            obscureText:
                                true, // Oculta el texto para que no se vea la contraseña (muestra puntos)
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white, // fondo blanco
                              labelText: "Contraseña",
                              labelStyle: TextStyle(
                                color:
                                    Colors.grey[400], // etiqueta gris clarito
                              ),
                              iconColor: const Color.fromARGB(255, 39, 2, 2),

                              // Borde normal (no enfocado)
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .grey[400]!, // un poquito más oscuro que antes
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(
                                  4,
                                ), // radio consistente
                              ),

                              // Borde enfocado
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .grey[500]!, // borde más oscuro cuando se toca
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),

                              // Borde de error
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors
                                  .black87, // texto ingresado negro legible
                            ),
                            validator: (valor) {
                              // Función que valida el texto ingresado
                              if (valor == null || valor.length < 6) {
                                return 'Mínimo 6 caracteres'; // Si está vacío o tiene menos de 6 caracteres, devuelve este error
                              }
                              return null; //si no devuelve null
                            },
                          ),
                          const SizedBox(height: 24), //espacio
                          _cargaDeDatos // dice si carga de datos true muestra en indicador circular si no false muestra el boton de iniciar iniciar sesion
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: iniciarSesion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: miColor,

                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Ingresar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                          const SizedBox(height: 12), // espacio
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                'register',
                              ); //para navegar a la pantalla segister
                            },
                            child: Text(
                              "¿No tienes cuenta? Regístrate aquí", //texto que se ve en el boton
                              style: TextStyle(
                                color: Color.fromARGB(255, 39, 2, 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*che importante se verifica que los datos ingresados sean validos porque haci
 se ahoran consultas innecesarias a la base de datos por 1000 usos por dia se puede con auth
*/