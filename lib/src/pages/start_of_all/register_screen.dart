import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//  Widget de estado mutable
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

//controladores de los campo del formulario de registro
class _RegisterScreenState extends State<RegisterScreen> {
  final _claveDeFormulario = GlobalKey<FormState>();
  //Text edit controller es una clase de flutter para controlar espacios completatables las declaro como final porque son constantes en tiempo de ejecuacion
  final TextEditingController nombre = TextEditingController();
  final TextEditingController apellido = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasenia = TextEditingController();
  final TextEditingController confirmarContrasenia = TextEditingController();

  bool _cargaDeDatos = false; // carga de datos empieza en false

  bool _mostrarContrasenia = false;
  bool _mostrarConfirmarContrasenia = false;

  Future<void> registrarUsuario() async {
    //depues de completar una vez que se toca regritrase empieza esta funcion
    if (_claveDeFormulario.currentState!.validate()) {
      //si el formulario esta completo ! y se validan los campor entonces
      setState(() {
        _cargaDeDatos =
            true; //carga de datos empieza a mostrar un widget de progreso
      });

      //Procesamos un poco lo datos ingresados
      final correoFinal = correo.text.trim().toLowerCase();
      final contraseniaFinal = contrasenia.text.trim();
      final nombreFinal = nombre.text.trim();
      final apellidoFinal = apellido.text.trim();

      try {
        // intentamos crear el usuario en Firebase Authentication
        final UserCredential credenciales = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: correoFinal,
              password: contraseniaFinal,
            );

        final uid = credenciales.user!.uid;

        // Guardar información adicional en Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'nombre': nombreFinal,
          'apellido': apellidoFinal,
          'correo': correoFinal,
          'rol': 'usuario',
          'activo': true, //dato que utilizare para un widget para banear ahhh
          'primerInicio': true, //dato que utilizare para un widget me ahhhhh
        });
        // Redirigir al login remplazando la pantalla actual
        Navigator.pushReplacementNamed(
          context,
          'login',
        ); //o sino hay un error y hay tres casos
      } on FirebaseAuthException catch (e) {
        String mensajeDeError = 'Ocurrió un error';
        if (e.code == 'email-already-in-use') {
          mensajeDeError = 'El correo ya está en uso.';
        } else if (e.code == 'weak-password') {
          mensajeDeError = 'La contraseña es muy débil.';
        } else if (e.code == 'invalid-email') {
          mensajeDeError = 'Correo inválido.';
        }

        //otros posibles errores que se capturan
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(mensajeDeError)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar usuario')),
        );
      } finally {
        setState(() {
          _cargaDeDatos = false; // una vez que este proceso termina se apaga
        });
      }
    }
  }

  //se empieza a construir la interfaz grafica casi igual que en login screen si algo no es igual comento
  @override
  Widget build(BuildContext context) {
    String hexColor = '#8e0b13';
    // Convierte la cadena hexadecimal a un entero, omitiendo el '#'
    int colorValue = int.parse(hexColor.substring(1), radix: 16);

    // Crea un objeto Color con el valor entero
    Color miColor = Color(
      colorValue | 0xFF000000,
    ); // Agrega el canal alfa (FF para opaco)
    const cremita = Colors.white;
    const rojoOscuro = Color.fromARGB(255, 39, 2, 2);

    return Scaffold(
      backgroundColor: miColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(color: cremita),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Registro Anecdótico',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Form(
                      key: _claveDeFormulario,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 39, 2, 2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            //en este texFormField el usurio ingresa su nombre y dsp lo mismo que en login
                            controller: nombre,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white, // fondo blanco
                              labelText: 'Nombre',
                              labelStyle: TextStyle(
                                color: Colors
                                    .grey[400], // etiqueta gris clarito cuando no está enfocado
                              ),
                              iconColor: const Color.fromARGB(255, 39, 2, 2),

                              // Borde normal (no enfocado)
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      Colors.grey[300]!, // borde gris clarito
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(
                                  4,
                                ), // radio redondeado
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
                                ), // mismo radio que enabled
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

                            validator: (value) =>
                                value!.isEmpty ? 'Ingresa tu nombre' : null,
                          ),
                          const SizedBox(height: 16), // espacio
                          TextFormField(
                            //en este texFormField el usurio ingresa su apellido y dsp lo mismo que en login
                            controller: apellido,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white, // fondo blanco
                              labelText: 'Apellido',
                              labelStyle: TextStyle(
                                color:
                                    Colors.grey[400], // etiqueta gris clarito
                              ),
                              iconColor: const Color.fromARGB(255, 39, 2, 2),

                              // Borde normal (no enfocado)
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .grey[300]!, // borde finito y un poco más oscuro
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(
                                  4,
                                ), // radio redondeado
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

                            validator:
                                (
                                  value,
                                ) => //verificamos que el field no este vacio si esta vacio ingrese su apellido sino null
                                value!.isEmpty
                                ? 'Ingresa tu apellido'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: correo,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white, // fondo blanco
                              labelText: 'Correo electrónico',
                              labelStyle: TextStyle(
                                color:
                                    Colors.grey[400], // etiqueta gris clarito
                              ),
                              iconColor: const Color.fromARGB(255, 39, 2, 2),

                              // Borde normal (no enfocado)
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors
                                      .grey[300]!, // borde finito y un poco más oscuro
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(
                                  4,
                                ), // radio redondeado
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

                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.isEmpty) return 'Ingresa tu correo';
                              final verificacionDeCorreo = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              return verificacionDeCorreo.hasMatch(value)
                                  ? null
                                  : 'Correo no válido';
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: contrasenia,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Contraseña',
                              labelStyle: TextStyle(color: Colors.grey[400]),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _mostrarContrasenia
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _mostrarContrasenia = !_mostrarContrasenia;
                                  });
                                },
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[500]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
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
                            style: const TextStyle(color: Colors.black87),
                            obscureText: !_mostrarContrasenia,
                            validator: (value) => value!.length < 6
                                ? 'Mínimo 6 caracteres'
                                : null,
                          ),

                          const SizedBox(height: 16), //espacio
                          TextFormField(
                            controller: confirmarContrasenia,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Confirmar contraseña',
                              labelStyle: TextStyle(color: Colors.grey[400]),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _mostrarConfirmarContrasenia
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _mostrarConfirmarContrasenia =
                                        !_mostrarConfirmarContrasenia;
                                  });
                                },
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[500]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black87),
                            obscureText:
                                !_mostrarConfirmarContrasenia, // cambio
                            validator: (value) => value != contrasenia.text
                                ? 'Las contraseñas no coinciden'
                                : null,
                          ),

                          const SizedBox(height: 24),
                          _cargaDeDatos
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  //si todo esta bien se puede registrar sin problema
                                  onPressed: registrarUsuario,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: miColor,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Registrarse',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, 'login');
                            },
                            child: const Text(
                              '¿Ya tienes cuenta? Inicia sesión aquí',
                              style: TextStyle(color: rojoOscuro),
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
