import 'package:flutter/material.dart';

class SelectorCategoria extends StatelessWidget {
  final String valorActual;
  final List<String> opciones;
  final ValueChanged<String?> onChanged;

  const SelectorCategoria({
    super.key,
    required this.valorActual,
    required this.opciones,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: DropdownButtonFormField<String>(
        value: valorActual,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(24),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 20, right: 10),
            child: Icon(Icons.category_rounded, color: Color(0xFFF26B2A), size: 24),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        ),
        items: opciones.map((String categoria) {
          return DropdownMenuItem<String>(
            value: categoria,
            child: Text(categoria),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}