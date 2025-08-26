import 'package:flutter/material.dart';

class DesktopAdminHomeScreen extends StatelessWidget {
  const DesktopAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: 0,
            onDestinationSelected: (index) {},
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text("Inicio"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text("Historial"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text("Configuración"),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          const Expanded(
            child: Center(child: Text("Contenido de escritorio aquí")),
          ),
        ],
      ),
    );
  }
}
