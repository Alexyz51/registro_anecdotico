import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

// Pantallas importadas
import 'package:registro_anecdotico/src/pages/splash_screen.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/home_screen.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/login_screen.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/register_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/common_user/common_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/edit_list_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/users_list_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/about_app_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/records_summary_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/config_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/historial_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());

  // Configuración ventana Windows
  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = const Size(600, 400);
    win.size = const Size(900, 600);
    win.alignment = Alignment.center;
    win.title = "Registro Anecdótico"; // 👈 cambia el texto aquí
    win.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _loadThemeFromPrefs();
  }

  // 🔑 Cargar tema desde SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode') ?? 'system';

    setState(() {
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  // 🔑 Cambiar tema y guardar en SharedPreferences
  void changeTheme(ThemeMode newTheme) async {
    setState(() {
      _themeMode = newTheme;
    });

    final prefs = await SharedPreferences.getInstance();
    String themeString = 'system';
    if (newTheme == ThemeMode.light) themeString = 'light';
    if (newTheme == ThemeMode.dark) themeString = 'dark';
    await prefs.setString('themeMode', themeString);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Tema claro
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF8e0b13),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8e0b13),
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
        ),
      ),

      // Tema oscuro
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF8e0b13),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8e0b13),
          foregroundColor: Colors.white,
        ),
        cardColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white70),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF2C2C2C),
          border: OutlineInputBorder(),
        ),
      ),

      themeMode: _themeMode,

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
        "about_app": (context) => const AboutAppScreen(),
        "records_summary": (context) => const RecordsSummaryScreen(),
        "historial": (context) => HistorialScreen(),
        "config": (context) => const ConfigScreen(),
      },
    );
  }
}




/*import 'package:flutter/material.dart';
//import 'package:registro_anecdotico/src/pages/admin_user/escolar_basica.dart';
import 'package:registro_anecdotico/src/pages/admin_user/historial_screen.dart';
//import 'package:registro_anecdotico/src/pages/admin_user/nivel_medio_screen.dart';
import 'package:registro_anecdotico/src/pages/splash_screen.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/home_screen.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/login_screen.dart';
import 'package:registro_anecdotico/src/pages/start_of_all/register_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/common_user/common_user_home_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/edit_list_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/users_list_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/about_app_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/records_summary_screen.dart';
import 'package:registro_anecdotico/src/pages/admin_user/config_screen.dart';
//import 'package:registro_anecdotico/src/pages/common_user/escolar_basica1.dart';
//import 'package:registro_anecdotico/src/pages/common_user/nivel_medio1.dart';
//import 'package:registro_anecdotico/src/pages/admin_user/historial_screen.dart';
//import 'package:registro_anecdotico/src/pages/common_user/abou_app_screen1.dart';
//import 'package:registro_anecdotico/src/pages/admin_user/lista_de_alumnos_escolar_basica_screen.dart';
//import 'package:registro_anecdotico/src/pages/admin_user/lista_alumnos_screen.dart';

// Importaciones de Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// En la funcion main me aseguro de que se cumplan las condiciones para que la app corra
// Nos aseguramos de que el sistema de flutter este listo y de tener configurado e instalado firebase
// Tipo la configuracion se hizo cuando instale firebase_CLI y cosas que esta en el discord
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// Pongo la estructura de un StatefulWidget pq vamos a necesitar cambiar el tema dinámicamente
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Para poder acceder al state desde cualquier pantalla y cambiar el tema
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode =
      ThemeMode.system; // Por defecto sigue el tema del sistema

  // Getter público para acceder al tema desde cualquier pantalla
  ThemeMode get themeMode => _themeMode;

  // Función que permite cambiar el tema desde cualquier pantalla
  void changeTheme(ThemeMode newTheme) {
    setState(() {
      _themeMode = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Tema claro
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF8e0b13),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8e0b13),
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      // Tema oscuro
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF8e0b13),
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8e0b13),
          foregroundColor: Colors.white,
        ),
        cardColor: Colors.grey[850],
        iconTheme: const IconThemeData(color: Colors.white70),
      ),

      // Indica qué tema usar
      themeMode: _themeMode,

      // Inicial
      initialRoute: "splash",

      // Rutas de la app
      routes: {
        "splash": (context) => const SplashScreen(),
        "home": (context) => const HomeScreen(),
        "login": (context) => const LoginScreen(),
        "register": (context) => const RegisterScreen(),
        "user_home": (context) => const CommonUserHomeScreen(),
        "admin_home": (context) => const AdminUserHomeScreen(),
        "edit_list": (context) => const EditListScreen(),
        "users_list": (context) => const UserListScreen(),
        //"nivel_medio": (context) => const NivelMedioScreen(),
        //"escolar_basica": (context) => const EscolarBasicaScreen(),
        "about_app": (context) => const AboutAppScreen(),
        "records_summary": (context) => const RecordsSummaryScreen(),
        "historial": (context) => HistorialScreen(),
        "config": (context) => const ConfigScreen(),
        //"lista_escolar": (context) => ListaAlumnosEscolarBasicaScreen(),
        //"historial": (context) => const HistorialScreen(),
        // Common user
        //"nivel_medio1": (context) => const NivelMedio1Screen(),
        //"escolar_basica1": (context) => const EscolarBasica1Screen(),
        //"about_app1": (context) => const AboutApp1Screen(),
      },
    );
  }
}
*/