import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SelectorImagenPlatillo extends StatelessWidget {
  final File? imagenFila;
  final String? imageUrl; 
  final VoidCallback onTapCamara;

  const SelectorImagenPlatillo({
    super.key, 
    required this.imagenFila, 
    this.imageUrl, 
    required this.onTapCamara
  });

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = Color(0xFFF26B2A);
    const Color bgColor = Color(0xFFF8F9FA);

    Widget imagenMostrar = const Center(child: Icon(Icons.restaurant, size: 50, color: Color(0xFFD1D5DB)));

    if (imagenFila != null) {
      imagenMostrar = Image.file(imagenFila!, fit: BoxFit.cover);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imagenMostrar = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: orangeColor)),
        errorWidget: (context, url, error) => const Center(child: Text('🌮', style: TextStyle(fontSize: 50))),
      );
    }

    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(45),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: ClipRRect(borderRadius: BorderRadius.circular(45), child: imagenMostrar),
          ),
          GestureDetector(
            onTap: onTapCamara, 
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: orangeColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: bgColor, width: 3)),
              child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}