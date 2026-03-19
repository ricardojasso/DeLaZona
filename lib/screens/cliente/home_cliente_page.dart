import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detalle_restaurante_page.dart'; 

class HomeClientePage extends StatefulWidget {
  const HomeClientePage({super.key});

  @override
  State<HomeClientePage> createState() => _HomeClientePageState();
}

class _HomeClientePageState extends State<HomeClientePage> {
  final Color primaryOrange = const Color(0xFFF97316);
  final Color darkBlue = const Color(0xFF0F172A);
  final Color bgColor = const Color(0xFFF8F9FA);

  String _textoBusqueda = "";

  final List<Color> _cardColors = [
    Colors.green.shade500,
    Colors.red.shade500,
    Colors.blue.shade500,
    Colors.purple.shade500,
    Colors.orange.shade500,
  ];

  // 🔥 AQUÍ ESTÁ EL CAMBIO: Función limpia para que el Enrutador tome el control
  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            // --- HEADER FIJO ---
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true,
              elevation: 0,
              toolbarHeight: 80,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              title: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Inter', fontStyle: FontStyle.italic),
                  children: [
                    const TextSpan(text: 'Restaurantes en ', style: TextStyle(color: Colors.black87)),
                    TextSpan(text: 'DeLaZona', style: TextStyle(color: primaryOrange)),
                  ],
                ),
              ),
              centerTitle: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 16.0, bottom: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 20),
                      onPressed: _cerrarSesion,
                      tooltip: 'Cerrar Sesión',
                    ),
                  ),
                )
              ],
            ),

            // --- BIENVENIDA Y BUSCADOR ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(
                      '¡Hola! ¿Qué se te antoja hoy?',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: darkBlue, height: 1.1),
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: TextField(
                        onChanged: (valor) {
                          setState(() {
                            _textoBusqueda = valor.toLowerCase();
                          });
                        },
                        style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Buscar restaurantes o comida...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 24, right: 12),
                            child: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 28),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      _textoBusqueda.isEmpty ? 'Restaurantes Disponibles' : 'Resultados de búsqueda',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: darkBlue),
                    ),
                  ],
                ),
              ),
            ),

            // --- LISTA DE RESTAURANTES DE FIREBASE ---
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('restaurantes').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(child: Text('Aún no hay restaurantes :(', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 18))),
                  );
                }

                var todosLosRestaurantes = snapshot.data!.docs;
                var restaurantesFiltrados = todosLosRestaurantes.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  
                  // 1. FILTRO DE ADMIN: Si el Master lo ocultó, no lo mostramos.
                  if (data['isVisible'] == false) return false;

                  // 2. FILTRO DE BÚSQUEDA DEL CLIENTE:
                  String nombre = (data['nombre_restaurante'] ?? '').toString().toLowerCase();
                  String descripcion = (data['descripcion'] ?? '').toString().toLowerCase();
                  
                  if (_textoBusqueda.isEmpty) return true;
                  return nombre.contains(_textoBusqueda) || descripcion.contains(_textoBusqueda);
                }).toList();

                if (restaurantesFiltrados.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text('No encontramos "$_textoBusqueda"', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        var restaurante = restaurantesFiltrados[index];
                        var data = restaurante.data() as Map<String, dynamic>;
                        
                        String nombre = data['nombre_restaurante'] ?? 'Restaurante';
                        String descripcion = data['descripcion'] ?? 'Deliciosa comida local';
                        String imagenUrl = data['foto_perfil'] ?? data['imagen_perfil'] ?? '';
                        bool isAbierto = data['is_abierto'] ?? true;
                        
                        // --- LÓGICA DE VIGENCIA DE LA PROMOCIÓN ---
                        String promocion = data['promocion'] ?? data['promociones'] ?? data['oferta'] ?? '';
                        Timestamp? fechaInicio = data['promocion_inicio'];
                        Timestamp? fechaFin = data['promocion_fin'];

                        if (promocion.isNotEmpty && fechaFin != null && fechaInicio != null) {
                          DateTime ahora = DateTime.now();
                          
                          DateTime inicio = fechaInicio.toDate();
                          inicio = DateTime(inicio.year, inicio.month, inicio.day, 0, 0, 0);
                          
                          DateTime fin = fechaFin.toDate();
                          fin = DateTime(fin.year, fin.month, fin.day, 23, 59, 59);
                          
                          if (ahora.isBefore(inicio) || ahora.isAfter(fin)) {
                            promocion = ''; 
                          }
                        }
                        
                        String tituloGigante = nombre.split(' ')[0].toUpperCase();
                        Color colorTarjeta = _cardColors[index % _cardColors.length];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleRestaurantePage(
                                  idRestaurante: restaurante.id,
                                  nombre: nombre,
                                  colorTema: colorTarjeta,
                                  tituloGigante: tituloGigante,
                                  descripcion: descripcion,
                                  direccion: data['direccion'] ?? 'Ubicación no disponible',
                                  whatsapp: data['whatsapp'] ?? '',
                                  imagenUrl: imagenUrl,
                                  promocion: promocion, 
                                  isAbierto: isAbierto, 
                                ),
                              ),
                            );
                          },
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
                                Container(
                                  height: 140,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: colorTarjeta,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                                    child: imagenUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: imagenUrl,
                                          width: double.infinity,
                                          height: 140,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(
                                            child: SizedBox(
                                              width: 30, height: 30, 
                                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                                            )
                                          ),
                                          errorWidget: (context, url, error) => Center(
                                            child: Text(tituloGigante, style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.95), fontStyle: FontStyle.italic, letterSpacing: -2)),
                                          ),
                                        )
                                      : Center(
                                          child: Text(tituloGigante, style: TextStyle(fontSize: 50, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.95), fontStyle: FontStyle.italic, letterSpacing: -2)),
                                        ),
                                  ),
                                ),
                                
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
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isAbierto ? Colors.green.shade50 : Colors.red.shade50, 
                                              borderRadius: BorderRadius.circular(20)
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 8, height: 8,
                                                  decoration: BoxDecoration(color: isAbierto ? Colors.green : Colors.red, shape: BoxShape.circle),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  isAbierto ? 'Abierto' : 'Cerrado', 
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isAbierto ? Colors.green.shade700 : Colors.red.shade700)
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: promocion.isNotEmpty
                                              ? Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                    margin: const EdgeInsets.only(right: 12),
                                                    decoration: BoxDecoration(color: Colors.orange.shade50, border: Border.all(color: Colors.orange.shade100), borderRadius: BorderRadius.circular(14)),
                                                    child: Text(
                                                      promocion.toUpperCase(), 
                                                      maxLines: 1, 
                                                      overflow: TextOverflow.ellipsis, 
                                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: primaryOrange, letterSpacing: 1.0)
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(), 
                                          ),
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
                      },
                      childCount: restaurantesFiltrados.length, 
                    ),
                  ),
                );
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }
}