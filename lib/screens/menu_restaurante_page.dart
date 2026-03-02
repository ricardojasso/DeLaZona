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

  Future<void> _borrarPlatillo(String idPlatillo) async {
    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('¿Borrar platillo?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        content: const Text('Esta acción no se puede deshacer.', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontSize: 16))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
            ),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Sí, borrar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
          ),
        ],
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
        toolbarHeight: 80, // AppBar más alto
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
              width: 55, // Botón + más grande
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

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var platillo = snapshot.data!.docs[index];
              var idPlatillo = platillo.id; 
              
              return Container(
                margin: const EdgeInsets.only(bottom: 20), // Más separación entre tarjetas
                padding: const EdgeInsets.all(16), // Tarjeta más acolchada
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28), // Bordes más redondos
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 6))],
                ),
                child: Row(
                  children: [
                    // Imagen del platillo (GIGANTE 90x90)
                    Container(
                      width: 90, height: 90, 
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        image: platillo['foto_url'] != '' ? DecorationImage(image: NetworkImage(platillo['foto_url']), fit: BoxFit.cover) : null,
                      ),
                      child: platillo['foto_url'] == '' ? const Center(child: Text('🌮', style: TextStyle(fontSize: 40))) : null,
                    ),
                    const SizedBox(width: 20),
                    // Detalles
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
                              // Botones de acción Escalados
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => EditarPlatilloPage(idPlatillo: idPlatillo, datosActuales: platillo.data() as Map<String, dynamic>)
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
                                    onTap: () => _borrarPlatillo(idPlatillo),
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
            },
          );
        },
      ),
    );
  }
}