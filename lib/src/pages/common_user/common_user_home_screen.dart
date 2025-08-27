/*import 'package:flutter/material.dart';

class CommonUserHomeScreen extends StatefulWidget {
  const CommonUserHomeScreen({super.key});

  @override
  State<CommonUserHomeScreen> createState() => _CommonUserHomeScreenState();
}

class _CommonUserHomeScreenState extends State<CommonUserHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pantalla de Usuario')),
      body: const Center(child: Text('¡Bienvenida, Usuario!')),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'mobile_common_user_home_screen.dart';
import 'desktop_common_user_home_screen.dart';

class CommonUserHomeScreen extends StatelessWidget {
  const CommonUserHomeScreen({super.key});

  bool esPantallaGrande(BuildContext context) {
    return MediaQuery.of(context).size.width >= 800;
  }

  @override
  Widget build(BuildContext context) {
    if (esPantallaGrande(context)) {
      return const DesktopAdminHomeUserScreen();
    } else {
      return const MobileAdminHomeUserScreen();
    }
  }
}
