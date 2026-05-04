import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/auth/campo_texto_personalizado.dart';
import '../cliente/home_cliente_page.dart';

class RegistroClienteView extends StatefulWidget {
  final VoidCallback volverAlLogin;
  const RegistroClienteView({super.key, required this.volverAlLogin});

  @override
  State<RegistroClienteView> createState() => _RegistroClienteViewState();
}

class _RegistroClienteViewState extends State<RegistroClienteView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrarCliente() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      UserCredential credencial = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(), password: _passCtrl.text.trim(),
      );
      await FirebaseFirestore.instance.collection('clientes').doc(credencial.user!.uid).set({
        'email': _emailCtrl.text.trim(),
        'rol': 'cliente',
        'fecha_registro': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('¡Cuenta creada!'), backgroundColor: Colors.green));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeClientePage()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Error al registrar cuenta.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF3B82F6);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Nuevo Cliente', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: blueColor)),
          const SizedBox(height: 32),
          CampoTextoPersonalizado(controlador: _emailCtrl, etiqueta: 'Email', hintText: 'tu@email.com', validador: (v) => v == null || v.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 16),
          CampoTextoPersonalizado(controlador: _passCtrl, etiqueta: 'Contraseña', hintText: 'Min. 6 caracteres', esPassword: true, validador: (v) => v != null && v.length < 6 ? 'Min 6 caracteres' : null),
          const SizedBox(height: 16),
          CampoTextoPersonalizado(controlador: _confirmCtrl, etiqueta: 'Confirmar Contraseña', hintText: '........', esPassword: true, validador: (v) => v != _passCtrl.text ? 'No coinciden' : null),
          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: _isLoading ? null : _registrarCliente,
            style: ElevatedButton.styleFrom(backgroundColor: blueColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Crear Cuenta de Cliente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: widget.volverAlLogin, // Usamos el cable para regresar
            child: const Text('← Volver al Acceso Principal', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}