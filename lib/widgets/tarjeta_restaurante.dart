import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TarjetaRestaurante extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String imagenUrl;
  final String tituloGigante;
  final Color colorTema;
  final bool isAbierto;
  final String promocion;
  final VoidCallback onTap;

  const TarjetaRestaurante({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.imagenUrl,
    required this.tituloGigante,
    required this.colorTema,
    required this.isAbierto,
    required this.promocion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryOrange = const Color(0xFFF97316);
    final Color darkBlue = const Color(0xFF0F172A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER DE LA TARJETA (IMAGEN) ---
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(color: colorTema, borderRadius: const BorderRadius.vertical(top: Radius.circular(40))),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                child: imagenUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imagenUrl,
                        width: double.infinity,
                        height: 140,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                            child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))),
                        errorWidget: (context, url, error) => _buildTituloGigante(),
                      )
                    : _buildTituloGigante(),
              ),
            ),

            // --- CUERPO DE LA TARJETA (TEXTOS) ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nombre, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkBlue, height: 1.1)),
                            const SizedBox(height: 6),
                            Text(descripcion, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
                          ],
                        ),
                      ),
                      // Etiqueta Abierto/Cerrado
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: isAbierto ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 8, height: 8, decoration: BoxDecoration(color: isAbierto ? Colors.green : Colors.red, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(isAbierto ? 'Abierto' : 'Cerrado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isAbierto ? Colors.green.shade700 : Colors.red.shade700)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Promoción
                      Expanded(
                        child: promocion.isNotEmpty
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(color: Colors.orange.shade50, border: Border.all(color: Colors.orange.shade100), borderRadius: BorderRadius.circular(14)),
                                  child: Text(promocion.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryOrange, letterSpacing: 1.0)),
                                ),
                              )
                            : const SizedBox(),
                      ),
                      // Botón Ver Menú
                      Row(
                        children: [
                          Text('Ver Menú', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blue.shade500, letterSpacing: 1.0)),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.blue.shade500),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mini-función para dibujar las iniciales si no hay foto
  Widget _buildTituloGigante() {
    return Center(
      child: Text(tituloGigante, style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.95), fontStyle: FontStyle.italic, letterSpacing: -2)),
    );
  }
}