import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TarjetaPlatilloAdmin extends StatelessWidget {
  final Map<String, dynamic> platillo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TarjetaPlatilloAdmin({
    super.key, required this.platillo, required this.onEdit, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF0F172A);
    const Color orangeColor = Color(0xFFF26B2A);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 90, height: 90, 
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
            child: platillo['foto_url'] != null && platillo['foto_url'] != '' 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: platillo['foto_url'], fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFF26B2A)))),
                    errorWidget: (context, url, error) => const Center(child: Text('🌮', style: TextStyle(fontSize: 40))),
                  ),
                ) 
              : const Center(child: Text('🌮', style: TextStyle(fontSize: 40))),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(platillo['nombre'] ?? 'Platillo', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: darkBlue)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${platillo['precio']}', style: const TextStyle(color: orangeColor, fontWeight: FontWeight.w900, fontSize: 18)),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(14)),
                            child: Icon(Icons.edit_outlined, color: Colors.blue.shade600, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(14)),
                            child: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}