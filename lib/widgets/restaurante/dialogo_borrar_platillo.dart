import 'package:flutter/material.dart';

class DialogoBorrarPlatillo extends StatelessWidget {
  final String nombrePlatillo;

  const DialogoBorrarPlatillo({super.key, required this.nombrePlatillo});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            // Ícono Circular Anidado
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFFFFF0F0), shape: BoxShape.circle),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFFFFE4E4), shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 36),
              ),
            ),
            const SizedBox(height: 24),
            const Text("¿Deseas eliminarlo?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w700, height: 1.5, fontFamily: 'Inter'),
                children: [
                  const TextSpan(text: "Vas a eliminar "),
                  TextSpan(text: nombrePlatillo, style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900)),
                  const TextSpan(text: "\npermanentemente de tu menú. Esta\nacción no se puede revertir."),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, elevation: 6,
                shadowColor: const Color(0xFFEF4444).withOpacity(0.4), minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context, true), // Devuelve TRUE si acepta
              child: const Text("CONFIRMAR BAJA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 12),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF8FAFC), foregroundColor: const Color(0xFF64748B),
                minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context, false), // Devuelve FALSE si cancela
              child: const Text("CANCELAR", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}