import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registro_cliente_page.dart';
import 'registro_restaurante_page.dart';
import 'panel_restaurante_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Variable para controlar el estado de carga sin usar showDialog
  bool _isLoading = false;

  Future<void> _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      
      setState(() {
        _isLoading = true;
      });

      try {
        //Iniciar sesión
        UserCredential credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String uid = credencial.user!.uid;
        String nombreUsuario = '';
        String rolUsuario = '';

        DocumentSnapshot docCliente = await FirebaseFirestore.instance.collection('clientes').doc(uid).get();

        if (docCliente.exists) {
          rolUsuario = "cliente";
          nombreUsuario = 'cliente';
        } else {
          DocumentSnapshot docRestaurante = await FirebaseFirestore.instance.collection('restaurantes').doc(uid).get();
          
          if (docRestaurante.exists) {
            rolUsuario = 'restaurante';
            nombreUsuario = docRestaurante['nombre_restaurante'] ?? 'Restaurante';
          }
        }

        if (rolUsuario.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bienvenido, $nombreUsuario'),
                backgroundColor: const Color(0xFFF26B2A),
              ),
            );
            
            if (rolUsuario == 'restaurante') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PanelRestaurantePage()),
              );
            } else if (rolUsuario == 'cliente') {
              print("Falta crear la pantalla principal del cliente");
              setState(() {
                _isLoading = false;
              });
            }
          }
        } else {
           if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Datos del usuario no encontrados.'), backgroundColor: Colors.red),
            );
           }
        }

      } on FirebaseAuthException catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        
        String mensaje = 'Error al iniciar sesión';
        if (e.code == 'user-not-found') {
          mensaje = 'No existe usuario con ese correo.';
        } else if (e.code == 'wrong-password') {
          mensaje = 'Contraseña incorrecta.';
        } else if (e.code == 'invalid-credential') {
          mensaje = 'Correo o contraseña incorrectos.'; 
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFF26B2A); 

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
                                TextSpan(
                                  text: 'DeLa',
                                  style: TextStyle(color: orangeColor),
                                ),
                                TextSpan(
                                  text: 'Zona',
                                  style: TextStyle(color: Colors.black),
                                ),
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

                        // "Iniciar Sesión"
                        const Text(
                          'Iniciar Sesión',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 32),

                        // Email
                        const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'tu@email.com',
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa tu email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Contraseña
                        const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '........',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 24, letterSpacing: 2),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _iniciarSesion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orangeColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const SizedBox(
                                height: 24, 
                                width: 24, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                        ),
                        const SizedBox(height: 24),

                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          '¿Aun no tienes cuenta?',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),

                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegistroClientePage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.blue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Registrarme como Cliente', style: TextStyle(color: Colors.blue)),
                        ),
                        const SizedBox(height: 12),

                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegistroRestaurantePage(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: orangeColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Registrar mi Restaurante', style: TextStyle(color: orangeColor)),
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
}