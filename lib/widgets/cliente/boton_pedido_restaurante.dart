import 'package:flutter/material.dart';

class BotonPedidoRestaurante extends StatelessWidget {
  final int totalItems;
  final bool isAbierto;
  final bool tieneWhatsapp;
  final VoidCallback onHacerPedido;

  const BotonPedidoRestaurante({
    super.key, required this.totalItems, required this.isAbierto, required this.tieneWhatsapp, required this.onHacerPedido
  });

  @override
  Widget build(BuildContext context) {
    bool activo = isAbierto && tieneWhatsapp;
    Color color = isAbierto ? const Color(0xFF25D366) : Colors.grey.shade400;

    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.white, Colors.white.withOpacity(0.0)])),
        child: ElevatedButton.icon(
          onPressed: activo ? onHacerPedido : null,
          icon: Icon(isAbierto ? Icons.chat_bubble_rounded : Icons.lock_clock_rounded, color: Colors.white),
          label: Text(!isAbierto ? "Cerrado" : totalItems > 0 ? "Pedir $totalItems Platillos" : "Hacer Consulta", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          style: ElevatedButton.styleFrom(backgroundColor: color, disabledBackgroundColor: color, minimumSize: const Size(double.infinity, 65), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        ),
      ),
    );
  }
}