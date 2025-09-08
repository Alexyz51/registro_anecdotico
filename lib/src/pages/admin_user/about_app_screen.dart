import 'package:flutter/material.dart';
//import 'config_screen.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> glosario = [
    {
      'palabra': 'Introducción',
      'descripcion':
          'Esta aplicación permite registrar conductas de los alumnos de manera digital, organizando la información por nivel, grado y sección.\n\n'
          'Permite asignar colores a las conductas, agregar comentarios y enviar notificaciones a los padres (solo si su correo fue previamente regirtrado).',
    },
    {
      'palabra': 'Privacidad y seguridad',
      'descripcion':
          'Los datos de profesores se almacenan en Firebase, con acceso seguro mediante autenticación.\n\n'
          'Cada usuario tiene un rol (profesor o administrador) que determina lo que puede ver o hacer.\n\n'
          'Las contraseñas se almacenan de manera segura (mrdiante Firebase Auth).',
    },
    {
      'palabra': 'Registro de usuario',
      'descripcion':
          'Abrir la aplicación y acceder a la pantalla Registro.\n\n'
          'Completar los campos obligatorios: Nombre, Apellido, Email y Contraseña.\n\n'
          'Seleccionar rol (por defecto: usuario) y presionar Registrarse.\n\n'
          'Tras el registro, se puede iniciar sesión con email y contraseña.',
    },
    {
      'palabra': 'Inicio de sesión',
      'descripcion':
          'Ingresar email y contraseña en la pantalla de inicio de sesión.\n\n'
          'Presionar Iniciar sesión para acceder al panel correspondiente según el rol.',
    },
    {
      'palabra': 'Registro de conductas',
      'descripcion':
          'Buscar al alumno en la a traves del cudro de Busqueda de Alumnos en la pantalla de inicio.\n\n'
          'Elegir un color de clasificación (verde, amarillo o rojo).\n\n'
          'Marcar las conductas frecuentes o agregar otra en Otros.\n\n'
          '(Opcional) Escribir un comentario o reflexión.\n\n'
          'Presionar Guardar para registrar la conducta. Un mensaje confirmará que se guardó correctamente.',
    },
    {
      'palabra': 'Envío de notificaciones',
      'descripcion':
          'Si está esta registrado (el correo del padre), la aplicación puede enviar un correo al padre del alumno con los detalles del registro automáticamente al guardar la conducta.',
    },
    {
      'palabra': 'Cierre de sesión',
      'descripcion':
          'Usar el botón de Cerrar sesión en el menú principal para proteger la cuenta en dispositivos compartidos.',
    },
    {
      'palabra': 'Recomendaciones',
      'descripcion':
          'Mantener la contraseña segura y no compartirla.\n\n'
          'Si se desea enviar notificaciones al los padres el correo debe estar registrado.\n\n'
          'Registrar siempre la conducta correcta y con honestidad para llevar un historial confiable.',
    },
  ];

  final Map<String, GlobalKey> itemKeys = {};

  @override
  void initState() {
    super.initState();
    for (var item in glosario) {
      itemKeys[item['palabra']!] = GlobalKey();
    }
  }

  void scrollearA(String palabra) {
    final key = itemKeys[palabra];
    if (key != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    const miColor = Color(0xFF8e0b13);

    final textColor = Theme.of(context).textTheme.bodyLarge!.color;
    final subtitleColor = Theme.of(context).textTheme.bodyMedium!.color;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: screenWidth < 800
          ? AppBar(
              backgroundColor: miColor,
              title: const Text(
                "Registro Anecdótico",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              centerTitle: true,
              automaticallyImplyLeading: true,
              elevation: 0,
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              title: Text(
                "Acerca de la Aplicación",
                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black, // blanco si dark, negro si claro
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                color: isDark
                    ? Colors.white
                    : Colors.black, // mismo comportamiento para icono
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              centerTitle: true,
              elevation: 0,
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            thickness: screenWidth > 800 ? 12 : 6,
            radius: const Radius.circular(6),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: glosario.map((item) {
                        return GestureDetector(
                          onTap: () => scrollearA(item['palabra']!),
                          child: Text(
                            item['palabra']!,
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    ...glosario.map((item) {
                      return Container(
                        key: itemKeys[item['palabra']],
                        margin: const EdgeInsets.only(bottom: 20),
                        width: double.infinity,
                        child: Card(
                          color: Theme.of(context).cardColor,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['palabra']!,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['descripcion']!,
                                  style: TextStyle(
                                    color: subtitleColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
