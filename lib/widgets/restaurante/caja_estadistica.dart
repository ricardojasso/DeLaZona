import 'package:flutter/material.dart';

class CajaEstadistica extends StatelessWidget {
  final String valor;
  final String etiqueta;

  const CajaEstadistica({
    super.key,
    required this.valor,
    required this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 6),
          Text(
            etiqueta,
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0),
          ),
        ],
      ),
    );
  }
}