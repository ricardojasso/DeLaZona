import 'package:flutter/material.dart';

class CabeceraPerfilRestaurante extends StatelessWidget {
  final String nombre;
  final String fotoPerfil;
  final VoidCallback onAjustesTap;

  const CabeceraPerfilRestaurante({
    super.key, required this.nombre, required this.fotoPerfil, required this.onAjustesTap
  });

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = Color(0xFFF26B2A);
    
    return Row(
      children: [
        Container(
          width: 60, height: 60, 
          decoration: BoxDecoration(color: orangeColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: orangeColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]),
          child: fotoPerfil.isNotEmpty
              ? ClipOval(child: Image.network(fotoPerfil, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Text('🔥', style: TextStyle(fontSize: 30)))))
              : const Center(child: Text('🔥', style: TextStyle(fontSize: 30))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              const Text('ADMINISTRADOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.5)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onAjustesTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
            child: Icon(Icons.settings_outlined, color: Colors.grey.shade600, size: 24),
          ),
        ),
      ],
    );
  }
}