import 'package:flutter/material.dart';
import 'config_screen.dart';
import '../widgets/breadcrumb_navigation.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  final ScrollController _scrollController = ScrollController();

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
          'Para hacer esto solo es copiar y pegar cambiando el texto y se genera automáticamente el item.',
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
