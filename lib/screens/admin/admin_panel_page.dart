import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  final Color orangeColor = const Color(0xFFF26B2A);
  String _searchTerm = "";

  // Función para suspender (ocultar de la vista del cliente)
  Future<void> _toggleVisibilidad(String docId, bool estadoActual) async {
    await FirebaseFirestore.instance.collection('restaurantes').doc(docId).update({
      'isVisible': !estadoActual 
    });
  }

  // DISEÑO DE BAJA DEFINITIVA
  Future<void> _eliminarNegocio(String docId, String nombre) async {
    await showDialog(
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F0),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE4E4), 
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 36),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "¿Deseas eliminarlo?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w700, height: 1.5, fontFamily: 'Inter'),
                  children: [
                    const TextSpan(text: "Vas a eliminar a "),
                    TextSpan(text: nombre, style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900)),
                    const TextSpan(text: "\npermanentemente de "),
                    const TextSpan(
                      text: "DeLaZona",
                      style: TextStyle(fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFF0F172A)),
                    ),
                    const TextSpan(text: ". Esta\nacción no se puede revertir."),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444), 
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: const Color(0xFFEF4444).withOpacity(0.4), 
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('restaurantes').doc(docId).delete();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("CONFIRMAR BAJA", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 12),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFF8FAFC), 
                  foregroundColor: const Color(0xFF64748B), 
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("CANCELAR", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER Y BUSCADOR ---
            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shield, color: orangeColor, size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                "Panel Maestro",
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          const Text(
                            "DeLaZona Admin",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => FirebaseAuth.instance.signOut(),
                        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 28),
                      )
                    ],
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    onChanged: (val) => setState(() => _searchTerm = val.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: "Buscar restaurante...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  )
                ],
              ),
            ),

            //CONTENIDO SCROLLABLE
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('restaurantes').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (!snapshot.hasData) return const SizedBox();

                  int online = snapshot.data!.docs.where((d) {
                    var data = d.data() as Map<String, dynamic>;
                    return data['isVisible'] != false; 
                  }).length;
                  int off = snapshot.data!.docs.length - online;

                  var docs = snapshot.data!.docs.where((d) {
                    var data = d.data() as Map<String, dynamic>;
                    return data['nombre_restaurante'].toString().toLowerCase().contains(_searchTerm);
                  }).toList();

                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                          child: Row(
                            children: [
                              _buildStatCard("EN LÍNEA", online.toString(), Colors.green),
                              const SizedBox(width: 15),
                              _buildStatCard("SUSPENDIDOS", off.toString(), Colors.red),
                            ],
                          ),
                        ),
                      ),

                      docs.isEmpty 
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Center(
                                child: Text("No se encontraron resultados", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  var data = docs[index].data() as Map<String, dynamic>;
                                  bool activo = data['isVisible'] != false; 

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 18),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 55, height: 55,
                                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(18)),
                                              child: const Center(child: Icon(Icons.storefront_rounded, color: Colors.blueGrey, size: 28)),
                                            ),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(data['nombre_restaurante'] ?? 'Negocio', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.chat_bubble_outline_rounded, size: 10, color: Colors.green),
                                                      const SizedBox(width: 4),
                                                      Text(data['whatsapp'] ?? "Sin número", style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                           //Diseño menu puntos
                                            PopupMenuButton(
                                              color: Colors.white,
                                              elevation: 10,
                                              shadowColor: Colors.black.withOpacity(0.3),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              offset: const Offset(0, 45), // Esto lo empuja hacia abajo para que no tape el botón
                                              // 🔥 CORRECCIÓN: Quitamos el Container con borde negro y dejamos solo el ícono puro
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                                child: Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 24),
                                              ),
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'delete',
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                                        SizedBox(width: 12),
                                                        Text(
                                                          "BAJA DEFINITIVA",
                                                          style: TextStyle(
                                                            color: Color(0xFFEF4444), 
                                                            fontWeight: FontWeight.w900, 
                                                            fontSize: 12,
                                                            letterSpacing: 1.0,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              onSelected: (val) => _eliminarNegocio(docs[index].id, data['nombre_restaurante'] ?? 'este negocio'),
                                            )
                                          ],
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 15),
                                          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: activo ? Colors.green.shade50 : Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Text(
                                                activo ? "ACTIVO" : "SUSPENDIDO",
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: activo ? Colors.green : Colors.red, letterSpacing: 1),
                                              ),
                                            ),
                                            Switch(
                                              value: activo, 
                                              activeThumbColor: Colors.green,
                                              inactiveTrackColor: Colors.red.shade200,
                                              onChanged: (val) => _toggleVisibilidad(docs[index].id, activo),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                                childCount: docs.length,
                              ),
                            ),
                          )
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(val, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}