import 'package:flutter/material.dart';

class EtiquetaFormulario extends StatelessWidget {
  final String texto;
  
  const EtiquetaFormulario({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Text(
        texto, 
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade400, letterSpacing: 2.0)
      ),
    );
  }
}