import 'package:flutter/material.dart';
import 'package:registro_anecdotico/src/pages/admin_user/admin_user_home_screen.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => AdminUserHomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      color: Colors.blue,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['descripcion']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
