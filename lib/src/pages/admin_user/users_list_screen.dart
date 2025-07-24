import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//para acceder en tiempo real a la base de datos
class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  Future<void> _borrarUsuario(String userId) async {
    //esta es un funcion es para que con el ID del usuario accedamos a la
    //coleccion users y borremos su documento porque su ID es el documento
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }

  //se construye la interfaz
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Usuarios'),
        leading: BackButton(
          onPressed: () => Navigator.pop(context, 'user_home'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        //Por aqui agregare el breadcrum cuando lo arregle
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(), //Uso un StreamBuilder para escuchar en tiempo real los cambios en la colección users
        builder: (context, snapshot) {
          //construye una pantalla de acuerdo al estado si hay un error o no pero tardan en llegar los daros sucede la condicion
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar usuarios'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final usuarios = snapshot
              .data!
              .docs; //.data! accede al QuerySnapshot (los datos de la colección)
          //.docs es una lista de documentos (List<QueryDocumentSnapshot>) y cada documento es un usuario registrdo

          if (usuarios.isEmpty) {
            //Si no hay usuarios muestra esl mensaje
            return const Center(child: Text('No hay usuarios registrados.'));
          }

          //Mostrar la lista de usuarios
          return ListView.builder(
            //crea una lista desplazable
            itemCount: usuarios.length, //define cuantos elementos va a tener
            itemBuilder: (context, index) {
              //construye cada elemento (usuario de la lista)
              final usuario =
                  usuarios[index]; //es un documento individual (QueryDocumentSnapshot)
              final datos =
                  usuario.data()
                      as Map<
                        String,
                        dynamic
                      >; //trae los datos del usuario como un mapa (Map<String, dynamic>)

              //traemos cada valor del mapa y ?? significa que si el campo no existe va a estar vacio
              final nombre = datos['nombre'] ?? '';
              final apellido = datos['apellido'] ?? '';
              final correo = datos['correo'] ?? '';
              final rol = datos['rol'] ?? '';

              //con esto hacemos que los datos adicionales no se muestren solo un titulo $nombre$apellido y los
              // datos adionales estan escondidos en la lista expancible
              return ExpansionTile(
                title: Text('$nombre $apellido'),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Correo: $correo'),
                        Text('Rol: $rol'),
                        //Boton para eliminar usuario, abre dialodo de confirmacion antes utlizar la funcion _borrarUsuario
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.delete,
                              color: Color.fromARGB(255, 120, 2, 255),
                            ),
                            label: const Text('Eliminar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              //accion de eliminar
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

                              //una vez que se oprime el botton en onopressed se confirma a accion y se ejecuta la funcion
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
              );
            },
          );
        },
      ),
    );
  }
}
