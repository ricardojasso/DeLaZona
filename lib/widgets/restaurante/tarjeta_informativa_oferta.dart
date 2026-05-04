import 'package:flutter/material.dart';

class TarjetaInformativaOferta extends StatelessWidget {
  const TarjetaInformativaOferta({super.key});

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = Color(0xFFF26B2A);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: orangeColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: orangeColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 16),
          const Text('OFERTA DEL DÍA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2.0)),
          const SizedBox(height: 8),
          Text('VISIBLE PARA TODOS TUS CLIENTES\nLOCALES', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        ],
      ),
    );
  }
}