import 'package:flutter/material.dart';
import 'login_view.dart';
import 'registro_cliente_view.dart';
import 'registro_restaurante_view.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // 0 = Login | 1 = Registro Cliente | 2 = Registro Restaurante
  int _vistaActual = 0;

  // (Callback)
  void _cambiarVista(int nuevaVista) {
    setState(() {
      _vistaActual = nuevaVista;
    });
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // LOGO FIJO
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, fontFamily: 'Arial'),
                          children: [
                            TextSpan(text: 'DeLa', style: TextStyle(color: orangeColor)),
                            TextSpan(text: 'Zona', style: TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Tu comunidad gastronómica local.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(height: 32),

                      // Cambiar vista
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _vistaActual == 0 
                          ? LoginView(
                              irARegistroCliente: () => _cambiarVista(1),
                              irARegistroRestaurante: () => _cambiarVista(2),
                            )
                          : _vistaActual == 1
                            ? RegistroClienteView(volverAlLogin: () => _cambiarVista(0))
                            : RegistroRestauranteView(volverAlLogin: () => _cambiarVista(0)),
                      ),
                    ],
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