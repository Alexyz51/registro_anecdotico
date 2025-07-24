import 'package:flutter/material.dart';
import '../widgets/breadcrumb_navigation.dart'; //Widget personalizado que creo ale

class AdminUserHomeScreen extends StatelessWidget {
  const AdminUserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //contruyo una lista tipo drawer (Menu lateral)
      drawer: Drawer(
        child: SafeArea(
          //par aevitar que el contenido solape algo
          child: ListView(
            //para tener varias acciones y que halla un scroll si haga falta
            padding: EdgeInsets.zero,
            children: [
              //encabezado
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 194, 208, 219),
                ),
                child: Text(
                  'Menú de Administrador',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              //opciones del menu
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar lista'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'edit_list');
                },
              ),
              ListTile(
                leading: const Icon(Icons.supervised_user_circle_sharp),
                title: const Text('Usuarios'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'users_list');
                },
              ),
              // Otras opciones se pueden agregar mas adelante
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
              recorrido: 'Inicio',
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
