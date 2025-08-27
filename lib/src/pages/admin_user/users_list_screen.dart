import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'admin_user_home_screen.dart';
//import 'package:registro_anecdotico/src/pages/common_user/common_user_home_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  Map<String, String> usuarioActual = {
    'nombre': '',
    'apellido': '',
    'rol': '',
    'rolReal': '',
  };

  Future<void> _borrarUsuario(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //String hexColor = '#8e0b13';
    const cremita = Colors.white;
    const miColor = Color(0xFF8e0b13);
    final isCelular = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: cremita,
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
          : null,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar usuarios'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final usuarios = snapshot.data!.docs;

          if (usuarios.isEmpty) {
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              final datos = usuario.data() as Map<String, dynamic>;

              final nombre = datos['nombre'] ?? '';
              final apellido = datos['apellido'] ?? '';
              final correo = datos['correo'] ?? '';
              final rolReal = datos['rolReal'] ?? '';
              final rol = datos['rol'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: isCelular
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$nombre $apellido',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('$rol', style: const TextStyle(fontSize: 12)),
                          ],
                        )
                      : Text(
                          '$nombre $apellido - $rolReal',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Correo: $correo'),
                          Text('$rolReal'),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              label: const Text('Eliminar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                final confirmar = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Confirmar eliminación'),
                                    content: Text(
                                      '¿Deseas eliminar a $nombre $apellido?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmar == true) {
                                  await _borrarUsuario(usuario.id);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
