import 'package:flutter/material.dart';

class InfoDetalleRestaurante extends StatelessWidget {
  final String nombre, descripcion, direccion, promocion;
  final bool isAbierto, isFollowing;
  final VoidCallback onToggleSeguir;

  const InfoDetalleRestaurante({
    super.key, required this.nombre, required this.descripcion, required this.direccion, 
    required this.promocion, required this.isAbierto, required this.isFollowing, required this.onToggleSeguir
  });

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = const Color(0xFF0F172A);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: darkBlue, height: 1.1)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: isAbierto ? Colors.green.shade50 : Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
                        child: Row(children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: isAbierto ? Colors.green : Colors.red, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(isAbierto ? 'Abierto' : 'Cerrado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isAbierto ? Colors.green.shade700 : Colors.red.shade700)),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(descripcion, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade500))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onToggleSeguir, 
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300), width: 60, height: 60,
                decoration: BoxDecoration(color: isFollowing ? Colors.red.shade500 : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isFollowing ? Colors.transparent : Colors.grey.shade200, width: 2)),
                child: Icon(isFollowing ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFollowing ? Colors.white : Colors.grey.shade400, size: 28),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(30)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('DIRECCIÓN:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
              const SizedBox(height: 4), Text(direccion, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
              if (promocion.isNotEmpty) ...[
                const SizedBox(height: 16), const Text('OFERTA ESPECIAL:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                const SizedBox(height: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.orange.shade500, borderRadius: BorderRadius.circular(12)), child: Text(promocion, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white))),
              ]
            ],
          ),
        ),
      ],
    );
  }
}