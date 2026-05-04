import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class HeaderDetalleRestaurante extends StatelessWidget {
  final String imagenUrl;
  final Color colorTema;
  final String tituloGigante;

  const HeaderDetalleRestaurante({super.key, required this.imagenUrl, required this.colorTema, required this.tituloGigante});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220.0, pinned: true, backgroundColor: colorTema, elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
        child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87), onPressed: () => Navigator.pop(context))),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(color: colorTema, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50))),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
            child: imagenUrl.isNotEmpty
              ? CachedNetworkImage(imageUrl: imagenUrl, fit: BoxFit.cover, errorWidget: (c,u,e) => _buildFallback())
              : _buildFallback(),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() => Center(child: Text(tituloGigante, style: const TextStyle(fontSize: 65, fontWeight: FontWeight.w900, color: Colors.white)));
}