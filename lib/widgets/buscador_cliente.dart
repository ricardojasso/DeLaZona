import 'package:flutter/material.dart';

class BuscadorCliente extends StatelessWidget {
  final Function(String) onChanged;

  const BuscadorCliente({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = const Color(0xFF0F172A);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Buscar restaurantes o comida...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 24, right: 12),
            child: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 28),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        ),
      ),
    );
  }
}