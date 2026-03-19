import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'agregar_platillo_page.dart';
import 'editar_platillo_page.dart';

class MenuRestaurantePage extends StatefulWidget {
  const MenuRestaurantePage({super.key});

  @override
  State<MenuRestaurantePage> createState() => _MenuRestaurantePageState();
}

class _MenuRestaurantePageState extends State<MenuRestaurantePage> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  final Color orangeColor = const Color(0xFFF26B2A);
  final Color darkBlue = const Color(0xFF0F172A);
  final Color bgColor = const Color(0xFFF8F9FA);

  // 🔥 Se agregó el parámetro 'nombrePlatillo' para mostrarlo en la advertencia
  Future<void> _borrarPlatillo(String idPlatillo, String nombrePlatillo) async {
    bool confirmar = await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // Ícono Circular Anidado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F0), // Rosa súper claro
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE4E4), // Rosa claro
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 36),
                ),
              ),
              const SizedBox(height: 24),
              // Título
              const Text(
                "¿Deseas eliminarlo?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              // Subtítulo con el nombre del platillo
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w700, height: 1.5, fontFamily: 'Inter'),
                  children: [
                    const TextSpan(text: "Vas a eliminar "),
                    TextSpan(text: nombrePlatillo, style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900)),
                    const TextSpan(text: "\npermanentemente de tu menú. Esta\nacción no se puede revertir."),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Botón Confirmar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444), // Rojo
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: const Color(0xFFEF4444).withOpacity(0.4), // Sombra iluminada
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text("CONFIRMAR BAJA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 12),
              // Botón Cancelar
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC), // Gris muy sutil
                  foregroundColor: const Color(0xFF64748B), // Texto gris azulado
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: const Text("CANCELAR", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ) ?? false;

    if (confirmar) {
      await FirebaseFirestore.instance.collection('platillos').doc(idPlatillo).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 2)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.blueGrey, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text('Mi Menú', style: TextStyle(color: darkBlue, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 26)),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0, top: 12, bottom: 12),
            child: Container(
              width: 55,
              decoration: BoxDecoration(color: orangeColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: orangeColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 28),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AgregarPlatilloPage())),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('platillos').where('id_restaurante', isEqualTo: _uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: orangeColor));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aún no tienes platillos', style: TextStyle(color: Colors.grey.shade400, fontSize: 18, fontWeight: FontWeight.bold)));
          }

          // 🔥 MAGIA DE AGRUPACIÓN POR CATEGORÍA 🔥
          Map<String, List<QueryDocumentSnapshot>> platillosAgrupados = {};
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            String categoria = data['categoria']?.toString().trim() ?? 'Otros';
            if (categoria.isEmpty) categoria = 'Otros';

            if (!platillosAgrupados.containsKey(categoria)) {
              platillosAgrupados[categoria] = [];
            }
            platillosAgrupados[categoria]!.add(doc);
          }

          // 🔥 NUEVO: Ordenar categorías exactamente como en la lista oficial 🔥
          final List<String> ordenDeseado = [
            'Entradas y Aperitivos',
            'Platos Fuertes',
            'Desayunos',
            'Bebidas',
            'Postres',
            'Snacks y Botanas',
            'Guarniciones o Extras',
            'Especialidades',
            'Otros'
          ];

          List<String> categorias = platillosAgrupados.keys.toList();
          categorias.sort((a, b) {
            int indexA = ordenDeseado.indexOf(a);
            int indexB = ordenDeseado.indexOf(b);
            // Si una categoría por alguna razón no está en la lista, la mandamos al final
            if (indexA == -1) indexA = 999;
            if (indexB == -1) indexB = 999;
            return indexA.compareTo(indexB);
          });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              String nombreCategoria = categorias[index];
              List<QueryDocumentSnapshot> platillosDeEstaCat = platillosAgrupados[nombreCategoria]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TÍTULO DE LA CATEGORÍA ---
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 12, left: 8),
                    child: Text(
                      nombreCategoria.toUpperCase(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.5),
                    ),
                  ),
                  
                  // --- LISTA DE PLATILLOS DE ESA CATEGORÍA ---
                  ...platillosDeEstaCat.map((platilloDoc) {
                    var platillo = platilloDoc.data() as Map<String, dynamic>;
                    var idPlatillo = platilloDoc.id; 
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 6))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 90, height: 90, 
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                            child: platillo['foto_url'] != '' 
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: CachedNetworkImage(
                                    imageUrl: platillo['foto_url'],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFFF26B2A)))),
                                    errorWidget: (context, url, error) => const Center(child: Text('🌮', style: TextStyle(fontSize: 40))),
                                  ),
                                ) 
                              : const Center(child: Text('🌮', style: TextStyle(fontSize: 40))),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(platillo['nombre'], style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: darkBlue)),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('\$${platillo['precio']}', style: TextStyle(color: orangeColor, fontWeight: FontWeight.w900, fontSize: 18)),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(
                                              builder: (context) => EditarPlatilloPage(idPlatillo: idPlatillo, datosActuales: platillo)
                                            ));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(14)),
                                            child: Icon(Icons.edit_outlined, color: Colors.blue.shade600, size: 20),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          // 🔥 Pasamos también el nombre del platillo a la función
                                          onTap: () => _borrarPlatillo(idPlatillo, platillo['nombre'] ?? 'este platillo'),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(14)),
                                            child: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}