import 'package:flutter/material.dart';

class InterruptorApertura extends StatelessWidget {
  final bool isAbierto;
  final ValueChanged<bool> onChanged;

  const InterruptorApertura({
    super.key, required this.isAbierto, required this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: isAbierto ? const Color(0xFFE8F8F0) : Colors.red.shade50, borderRadius: BorderRadius.circular(35)),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: isAbierto ? Colors.green : Colors.red, shape: BoxShape.circle)),
          const SizedBox(width: 14),
          Text(isAbierto ? 'Abierto' : 'Cerrado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: isAbierto ? Colors.green.shade800 : Colors.red.shade800)),
          const Spacer(),
          Switch(
            value: isAbierto, activeThumbColor: Colors.green, 
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}