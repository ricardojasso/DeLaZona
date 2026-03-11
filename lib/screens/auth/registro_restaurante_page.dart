import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroRestaurantePage extends StatefulWidget {
  const RegistroRestaurantePage({super.key});

  @override
  State<RegistroRestaurantePage> createState() => _RegistroRestaurantePageState();
}

class _RegistroRestaurantePageState extends State<RegistroRestaurantePage> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

Future<void> _registrarRestaurante() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Crear
        UserCredential credencial = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // 2. Guardar datos 
        await FirebaseFirestore.instance.collection('restaurantes').doc(credencial.user!.uid).set({
          'uid': credencial.user!.uid,
          'email': _emailController.text.trim(),
          'nombre_restaurante': _nombreController.text.trim(), 
          'rol': 'restaurante', 
          'fecha_registro': FieldValue.serverTimestamp(),
          'foto_perfil': '', 
          'descripcion': '',
          'direccion': '',
        });

        if (mounted) Navigator.pop(context);


        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Restaurante registrado con éxito!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); 
        }

      } on FirebaseAuthException catch (e) {
        if (mounted) Navigator.pop(context);

        String mensajeError = 'Ocurrió un error.';
        if (e.code == 'weak-password') {
          mensajeError = 'La contraseña es muy débil.';
        } else if (e.code == 'email-already-in-use') {
          mensajeError = 'Este correo ya está registrado.';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensajeError), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        print("Error no controlado: $e");
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFF26B2A);
    const blueColor = Color(0xFF3B82F6); 

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        Center(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Arial',
                              ),
                              children: [
                                TextSpan(text: 'DeLa', style: TextStyle(color: orangeColor)),
                                TextSpan(text: 'Zona', style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tu comunidad gastronómica local.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 32),

                        const Text(
                          'Nuevo Restaurante',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: blueColor),
                        ),
                        const SizedBox(height: 32),

                        //Nombre del Restaurante
                        const Text('Nombre del Restaurante', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nombreController,
                          textCapitalization: TextCapitalization.words,
                          decoration: _buildInputDecoration('Ej: Antojitos Doña Lupe'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa el nombre del restaurante';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        //Email
                        const Text('Email (para acceso)', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildInputDecoration('restaurante@gmail.com'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa tu email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        //Contraseña
                        const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: _buildInputDecoration('Min. 6 caracteres'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa una contraseña';
                            if (value.length < 6) return 'Debe tener al menos 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        //Confirmar Contraseña
                        const Text('Confirmar Contraseña', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: _buildInputDecoration(''),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Confirma tu contraseña';
                            if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Botón Crear Cuenta 
                        ElevatedButton(
                          onPressed: _registrarRestaurante,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orangeColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Crear Cuenta De Restaurante',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Botón volver atrás
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            '← Volver al Acceso Principal',
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}