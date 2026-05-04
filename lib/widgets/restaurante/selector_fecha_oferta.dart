import 'package:flutter/material.dart';

class SelectorFechaOferta extends StatelessWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final VoidCallback onTap;

  const SelectorFechaOferta({
    super.key, required this.fechaInicio, required this.fechaFin, required this.onTap
  });

  String _formatearFecha(DateTime date) => "${date.day}/${date.month}/${date.year}";

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = Color(0xFFF26B2A);
    const Color darkBlue = Color(0xFF0F172A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, color: orangeColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                fechaInicio != null && fechaFin != null
                    ? 'Del ${_formatearFecha(fechaInicio!)} al ${_formatearFecha(fechaFin!)}'
                    : 'Toca para seleccionar fechas...',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: fechaInicio != null ? darkBlue : Colors.grey.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}