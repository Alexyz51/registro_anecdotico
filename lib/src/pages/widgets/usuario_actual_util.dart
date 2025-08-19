import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, String>> obtenerUsuarioActual() async {
  final User? usuario = FirebaseAuth.instance.currentUser;
  if (usuario == null) return {};

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(usuario.uid)
      .get();

  if (!doc.exists) return {};

  final data = doc.data()!;
  return {
    'nombre': data['nombre'] ?? '',
    'apellido': data['apellido'] ?? '',
    'rol': data['rol'] ?? '',
    'rolReal': data['rolReal'] ?? '',
  };
}
