import 'package:flutter/material.dart';
import '../widgets/breadcrumb_navigation.dart';

class AdminUserHomeScreen extends StatelessWidget {
  const AdminUserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'Menú de Administrador',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar lista'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'edit_list');
                },
              ),
              // Otras opciones se pueden agregar más adelante
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        automaticallyImplyLeading: true, // Esto muestra la hamburguesa
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BreadcrumbBar(
          items: [
            BreadcrumbItem(
              label: 'Inicio',
              onTap: () {
                Navigator.pushReplacementNamed(context, 'admin_home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
