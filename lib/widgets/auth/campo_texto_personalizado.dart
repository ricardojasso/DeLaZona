import 'package:flutter/material.dart';

class CampoTextoPersonalizado extends StatelessWidget {
  final TextEditingController controlador;
  final String etiqueta; 
  final String hintText; 
  final IconData? icono; 
  final bool esPassword; 
  final TextInputType tipoTeclado;
  final String? Function(String?)? validador;

  const CampoTextoPersonalizado({
    super.key,
    required this.controlador,
    required this.etiqueta,
    required this.hintText,
    this.icono,
    this.esPassword = false, 
    this.tipoTeclado = TextInputType.text,
    this.validador,
  });

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFF26B2A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        
        TextFormField(
          controller: controlador,
          obscureText: esPassword,
          keyboardType: tipoTeclado,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey.shade400, 
              fontSize: esPassword ? 24 : 14, 
              letterSpacing: esPassword ? 2 : 0,
            ),
            prefixIcon: icono != null ? Icon(icono, color: orangeColor, size: 22) : null,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validador,
        ),
      ],
    );
  }
}