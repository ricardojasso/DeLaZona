import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TarjetaPlatillo extends StatelessWidget {
  final Map<String, dynamic> data;
  final String nombrePlatillo;
  final int cantidadActual;
  final Color colorTema;
  final bool isAbierto;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const TarjetaPlatillo({
    super.key,
    required this.data,
    required this.nombrePlatillo,
    required this.cantidadActual,
    required this.colorTema,
    required this.isAbierto,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    String fotoUrl = data['foto_url'] ?? '';
    final Color darkBlue = const Color(0xFF0F172A);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cantidadActual > 0 ? colorTema.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cantidadActual > 0 ? colorTema.withOpacity(0.5) : Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (fotoUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: fotoUrl, width: 75, height: 75, fit: BoxFit.cover,
                placeholder: (c, u) => Container(width: 75, height: 75, color: Colors.grey.shade100, child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF26B2A))))),
                errorWidget: (c, u, e) => Container(width: 75, height: 75, color: Colors.grey.shade100, child: Icon(Icons.fastfood, color: Colors.grey.shade400)),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombrePlatillo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                if (data['descripcion'] != null && data['descripcion'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4), 
                  Text(data['descripcion'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ]
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${data['precio']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkBlue)),
              const SizedBox(height: 8),
              if (isAbierto) _buildControlesCarrito(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlesCarrito() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: cantidadActual > 0 ? Colors.red.shade400 : Colors.grey.shade300, shape: BoxShape.circle), child: const Icon(Icons.remove, size: 16, color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$cantidadActual', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.green.shade500, shape: BoxShape.circle), child: const Icon(Icons.add, size: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}