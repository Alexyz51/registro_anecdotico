import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//  Widget de estado mutable
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

//controladores de los campor del formulario de registro
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  //Text edit controller es una clase de flutter para controlar espacios completatables
  final TextEditingController nombre = TextEditingController();
  final TextEditingController apellido = TextEditingController();
  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasenia = TextEditingController();
  final TextEditingController confirmarContrasenia = TextEditingController();

  bool _cargaDeDatos = false;

  Future<void> registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _cargaDeDatos = true;
      });

      final correoFinal = correo.text.trim().toLowerCase();
      final contraseniaFinal = contrasenia.text.trim();
      final nombreFinal = nombre.text.trim();
      final apellidoFinal = apellido.text.trim();

      try {
        // Crear el usuario en Firebase Authentication
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
        });

        // Redirigir al login
        Navigator.pushReplacementNamed(
          context,
          'login',
        ); //o sino hay un error y hay tres casos
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Ocurrió un error';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'El correo ya está en uso.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'La contraseña es muy débil.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Correo inválido.';
        }

        //otros posibles errores que se capturan
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar usuario')),
        );
      } finally {
        setState(() {
          _cargaDeDatos = false; // sino carga completada
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const azulGrisClaro = Color.fromARGB(255, 175, 183, 197);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/book.png', // Cambiar si el nombre es otro
                height: 100,
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: Card(
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
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Registro Anecdótico',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: azulGrisClaro,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: nombre,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Ingresa tu nombre' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: apellido,
                            decoration: const InputDecoration(
                              labelText: 'Apellido',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Ingresa tu apellido' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: correo,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              border: OutlineInputBorder(),
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
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) => value!.length < 6
                                ? 'Mínimo 6 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: confirmarContrasenia,
                            decoration: const InputDecoration(
                              labelText: 'Confirmar contraseña',
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (value) =>
                                value != confirmarContrasenia.text
                                ? 'Las contraseñas no coinciden'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          _cargaDeDatos
                              ? const CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: registrarUsuario,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: azulGrisClaro,
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Registrarse'),
                                ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, 'login');
                            },
                            child: const Text(
                              '¿Ya tienes cuenta? Inicia sesión aquí',
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
