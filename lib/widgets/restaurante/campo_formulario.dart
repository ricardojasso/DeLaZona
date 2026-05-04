import 'package:flutter/material.dart';

class CampoFormulario extends StatelessWidget {
  final TextEditingController controlador;
  final String hint;
  final IconData icono;
  final bool isNumber;
  final bool isPhone;
  final int maxLines;

  const CampoFormulario({
    super.key,
    required this.controlador,
    required this.hint,
    required this.icono,
    this.isNumber = false,
    this.isPhone = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    TextInputType tipoTeclado = TextInputType.text;
    if (isNumber) tipoTeclado = const TextInputType.numberWithOptions(decimal: true);
    if (isPhone) tipoTeclado = TextInputType.phone;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: controlador,
        keyboardType: tipoTeclado,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.normal),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Icon(icono, color: const Color(0xFFF26B2A), size: 24),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        ),
      ),
    );
  }
}