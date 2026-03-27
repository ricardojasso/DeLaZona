import 'package:flutter/material.dart';

class BotonNaranja extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool isLoading;

  const BotonNaranja({
    super.key,
    required this.texto,
    required this.onPressed,
    this.isLoading = false, 
  });

  @override
  Widget build(BuildContext context) {
    const orangeColor = Color(0xFFF26B2A);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: orangeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
              )
            : Text(
                texto,
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}