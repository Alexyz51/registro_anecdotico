import 'package:flutter/material.dart';
import 'common_user_home_screen.dart';
import '../widgets/breadcrumb_navigation.dart';

class AboutApp1Screen extends StatefulWidget {
  const AboutApp1Screen({super.key});

  @override
  State<AboutApp1Screen> createState() => _AboutApp1ScreenState();
}

class _AboutApp1ScreenState extends State<AboutApp1Screen> {
  final ScrollController _scrollController = ScrollController();

  // Lista de términos con sus descripciones
  final List<Map<String, String>> glosario = [
    {
      'palabra': 'Privacidad',
      'descripcion':
          'La privacidad se refiere a la protección de los datos personales del usuario...',
    },
    {
      'palabra': 'Seguridad',
      'descripcion':
          'La seguridad implica la protección contra accesos no autorizados...',
    },
    {
      'palabra': 'Licencia',
      'descripcion':
          'Una licencia define los términos legales para usar esta aplicación...',
    },
    {
      'palabra': 'Contacto',
      'descripcion':
          'Podés contactarnos a través del correo institucional o mediante el sitio web oficial.',
    },
    {
      'palabra': 'Otra Palabra',
      'descripcion':
          'Para hacer esto solo es copiar y pegar cambiando el texto como to hago y se genera automaticamente el item.',
    },
  ];

  // Mapa para almacenar las claves de cada palabra
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
    const cremita = const Color.fromARGB(248, 252, 230, 230);
    const rojoOscuro = Color.fromARGB(255, 39, 2, 2);
    //Paleta de colores habitual
    return Scaffold(
      backgroundColor: cremita,
      appBar: AppBar(
        backgroundColor: cremita,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => CommonUserHomeScreen()),
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          'Registro Anecdotico',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(226, 201, 183, 171),
          ),
        ),
        automaticallyImplyLeading: true,
        elevation: 0, // para que no tenga sombra propia
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0), // altura de la barra separadora
          child: Container(
            color: rojoOscuro, // tu color rojo oscuro declarado
            height: 5.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BreadcrumbBar(
              items: [
                BreadcrumbItem(
                  recorrido: 'Secciones',
                  onTap: () {
                    Navigator.pushReplacementNamed(context, 'user_home');
                  },
                ),
                BreadcrumbItem(recorrido: 'Acerca de la app'),
              ],
            ),
            const SizedBox(height: 24),
            // Glosario interactivo (tipo índice)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: glosario.map((item) {
                return GestureDetector(
                  onTap: () => scrollearA(item['palabra']!),
                  child: Text(
                    item['palabra']!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: rojoOscuro,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Contenido en tarjetas
            ...glosario.map((item) {
              return Container(
                key: itemKeys[item['palabra']],
                margin: const EdgeInsets.only(bottom: 20),
                child: Card(
                  color: const Color.fromARGB(248, 255, 243, 243),
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
                          style: const TextStyle(
                            color: Color.fromARGB(255, 201, 183, 171),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['descripcion']!,
                          style: const TextStyle(
                            color: rojoOscuro,
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
    );
  }
}
