import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth/boton_naranja.dart';
import '../../widgets/auth/campo_texto_personalizado.dart';
import '../restaurante/panel_restaurante_page.dart';

class RegistroRestauranteView extends StatefulWidget {
  final VoidCallback volverAlLogin;
  const RegistroRestauranteView({super.key, required this.volverAlLogin});

  @override
  State<RegistroRestauranteView> createState() => _RegistroRestauranteViewState();
}

class _RegistroRestauranteViewState extends State<RegistroRestauranteView> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final AuthService _authService = AuthService(); // <-- NUESTRA INSTANCIA DEL SERVICIO

  @override
  void dispose() {
    _nombreCtrl.dispose(); 
    _emailCtrl.dispose(); 
    _passCtrl.dispose(); 
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrarRestaurante() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await _authService.registrarRestaurante(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        nombreRestaurante: _nombreCtrl.text.trim(),
      );

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('¡Restaurante registrado con éxito!'), backgroundColor: Colors.green));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PanelRestaurantePage()));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Error al registrar restaurante. Revisa tus datos.'), backgroundColor: Colors.red));
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
          const Text('Nuevo Restaurante', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: blueColor)),
          const SizedBox(height: 32),
          CampoTextoPersonalizado(controlador: _nombreCtrl, etiqueta: 'Nombre del Restaurante', hintText: 'Ej: Antojitos Doña Lupe', validador: (v) => v == null || v.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 16),
          CampoTextoPersonalizado(controlador: _emailCtrl, etiqueta: 'Email (para acceso)', hintText: 'restaurante@gmail.com', tipoTeclado: TextInputType.emailAddress, validador: (v) => v == null || v.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 16),
          CampoTextoPersonalizado(controlador: _passCtrl, etiqueta: 'Contraseña', hintText: 'Min. 6 caracteres', esPassword: true, validador: (v) => v != null && v.length < 6 ? 'Min 6 caracteres' : null),
          const SizedBox(height: 16),
          CampoTextoPersonalizado(controlador: _confirmCtrl, etiqueta: 'Confirmar Contraseña', hintText: '........', esPassword: true, validador: (v) => v != _passCtrl.text ? 'No coinciden' : null),
          const SizedBox(height: 32),
          
          BotonNaranja(texto: 'Crear Cuenta De Restaurante', isLoading: _isLoading, onPressed: _registrarRestaurante),
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