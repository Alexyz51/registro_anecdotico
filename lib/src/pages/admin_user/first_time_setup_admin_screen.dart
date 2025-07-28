import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirstTimeSetupAdminScreen extends StatefulWidget {
  const FirstTimeSetupAdminScreen({super.key});

  @override
  State<FirstTimeSetupAdminScreen> createState() =>
      _FirstTimeSetupAdminScreenState();
}

class _FirstTimeSetupAdminScreenState extends State<FirstTimeSetupAdminScreen> {
  final List<String> cargos = [
    'Director',
    'Directora',
    'Secretario',
    'Secretaria',
  ];
  String? seleccionDeCargo;
  bool estaCargando = false;

  Future<void> _guardarCargo() async {
    if (seleccionDeCargo == null) return;

    setState(() => estaCargando = true);

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'cargo': seleccionDeCargo,
      });

      // Aquí podrías redirigir según el rol
      Navigator.pushReplacementNamed(context, 'admin_home');
    }

    setState(() => estaCargando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Primera vez')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¡Bienvenido/a!\nPor favor, selecciona tu cargo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            DropdownButton<String>(
              hint: const Text('Seleccionar cargo'),
              value: seleccionDeCargo,
              onChanged: (value) {
                setState(() {
                  seleccionDeCargo = value;
                });
              },
              items: cargos
                  .map(
                    (cargo) =>
                        DropdownMenuItem(value: cargo, child: Text(cargo)),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: estaCargando ? null : _guardarCargo,
              child: estaCargando
                  ? const CircularProgressIndicator()
                  : const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
