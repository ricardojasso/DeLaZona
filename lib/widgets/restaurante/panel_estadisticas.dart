import 'package:flutter/material.dart';
import 'caja_estadistica.dart'; // Importamos el widget pequeñito

class PanelEstadisticas extends StatelessWidget {
  final String totalSeguidores;
  final String totalWhatsApps;

  const PanelEstadisticas({
    super.key, required this.totalSeguidores, required this.totalWhatsApps
  });

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0F172A);
    const Color orangeColor = Color(0xFFF26B2A);

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: darkBlue, borderRadius: BorderRadius.circular(35), boxShadow: [BoxShadow(color: darkBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ACTIVIDAD DE HOY', style: TextStyle(color: orangeColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
              Icon(Icons.trending_up, color: orangeColor, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: CajaEstadistica(valor: totalSeguidores, etiqueta: 'SEGUIDORES')),
              const SizedBox(width: 20),
              Expanded(child: CajaEstadistica(valor: totalWhatsApps, etiqueta: 'WHATSAPPS')),
            ],
          ),
        ],
      ),
    );
  }
}