import 'package:flutter/material.dart';
import 'package:registro_anecdotico/src/pages/splash_screen.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/home_screen.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/login_screen.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/register_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/common_user/common_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/edit_list_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/users_list_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/first_time_setup_admin_screen.dart';
import 'package:registro_anecdotico/src/pages/common_user/first_time_setup_user_screen.dart';

// Importaciones de Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//En la funcion main me aseguro de que se cumplan las condiciones para que la app corra
//Nos aseguramos de que el sistema de flutter este listo y de tener configurado e instalado firebase
//Tipo la configuracion se hizo cuando instale firebase_CLI y cosas que esta en el discord
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

//Pongo la estructura de un statelessW pq voy a estar trabajado con
//estados no mutables que serian las rutas
class MyApp extends StatelessWidget {
  //para que sea inmutable
  const MyApp({super.key});

  //metodo obligatorio para mostrar pantalla bueno es este caso lo que me va a devolvel va a ser la
  //primera pantalla en un principio pero van a estar trazadas todas las rutas a seguir aqui
  @override
  Widget build(BuildContext context) {
    //simplemente retorna un Container, que no muestra nada visible.Es solo una plantilla vacía. Sirve para empezar a construir la app.
    //Pero yo le pongo MaterialApp que es como una funcion donde declarare la ruta inicial y todas las rutas (ruta=>pantalla)
    return MaterialApp(
      //propiedad boleana que "muestra un banner rojo de debug" esta desactivado
      debugShowCheckedModeBanner: false,

      initialRoute: "splash",

      routes: {
        "splash": (context) => const SplashScreen(),
        "home": (context) => const HomeScreen(),
        "login": (context) => const LoginScreen(),
        "register": (context) => const RegisterScreen(),
        "user_home": (context) => const CommonUserHomeScreen(),
        "admin_home": (context) => const AdminUserHomeScreen(),
        "edit_list": (context) => const EditListScreen(),
        "users_list": (context) => const UserListScreen(),
        "first_setup_admin": (context) => const FirstTimeSetupAdminScreen(),
        "first_setup_user": (context) => const FirstTimeSetupUserScreen(),
      },
    );
  }
}
