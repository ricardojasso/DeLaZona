import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/boton_naranja.dart';
import '../auth/campo_texto_personalizado.dart';
import '../../screens/restaurante/panel_restaurante_page.dart';
import '../../screens/cliente/home_cliente_page.dart';

class LoginView extends StatefulWidget {
  // Recibimos los "cables" desde el archivo maestro
  final VoidCallback irARegistroCliente;
  final VoidCallback irARegistroRestaurante;

  const LoginView({super.key, required this.irARegistroCliente, required this.irARegistroRestaurante});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      UserCredential credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(), password: _passCtrl.text.trim(),
      );

      String uid = credencial.user!.uid;
      String mensaje = 'Accediendo a DeLaZona...';
      Widget destino = const HomeClientePage(); // Por defecto para evitar nulos

      DocumentSnapshot docAdmin = await FirebaseFirestore.instance.collection('usuarios_roles').doc(uid).get();
      if (docAdmin.exists && (docAdmin.data() as Map<String, dynamic>)['role'] == 'admin') {
        mensaje = '¡Bienvenido, Administrador Maestro!';
      } else {
        DocumentSnapshot docRest = await FirebaseFirestore.instance.collection('restaurantes').doc(uid).get();
        if (docRest.exists) {
          mensaje = '¡Bienvenido, ${docRest['nombre_restaurante'] ?? 'Restaurante'}!';
          destino = const PanelRestaurantePage();
        } else {
          DocumentSnapshot docCli = await FirebaseFirestore.instance.collection('clientes').doc(uid).get();
          if (docCli.exists) {
            mensaje = '¡Bienvenido, Cliente!';
            destino = const HomeClientePage();
          }
        }
      }

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: const Color(0xFFF26B2A)));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => destino));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Error al iniciar sesión. Revisa tus datos.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFF26B2A);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Iniciar Sesión', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          CampoTextoPersonalizado(controlador: _emailCtrl, etiqueta: 'Email', hintText: 'tu@email.com', icono: Icons.email_outlined, tipoTeclado: TextInputType.emailAddress, validador: (v) => v == null || v.isEmpty ? 'Ingresa tu email' : null),
          const SizedBox(height: 24),
          CampoTextoPersonalizado(controlador: _passCtrl, etiqueta: 'Contraseña', hintText: '........', icono: Icons.lock_outline, esPassword: true, validador: (v) => v == null || v.isEmpty ? 'Ingresa tu contraseña' : null),
          const SizedBox(height: 32),
          BotonNaranja(texto: 'Entrar', isLoading: _isLoading, onPressed: _iniciarSesion),
          const SizedBox(height: 24),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('¿Aun no tienes cuenta?', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          
          OutlinedButton(
            onPressed: widget.irARegistroCliente, // Usamos el cable de conexión
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: Colors.blue), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Registrarme como Cliente', style: TextStyle(color: Colors.blue)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: widget.irARegistroRestaurante, // Usamos el cable de conexión
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: orangeColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Registrar mi Restaurante', style: TextStyle(color: orangeColor)),
          ),
        ],
      ),
    );
  }
}