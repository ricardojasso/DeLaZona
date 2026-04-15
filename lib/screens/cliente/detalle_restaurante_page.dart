import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

// --- IMPORTAMOS TODOS LOS WIDGETS ---
import '../../widgets/tarjeta_platillo.dart';
import '../../widgets/header_detalle_restaurante.dart';
import '../../widgets/info_detalle_restaurante.dart';
import '../../widgets/boton_pedido_restaurante.dart';

class DetalleRestaurantePage extends StatefulWidget {
  final String idRestaurante, nombre, tituloGigante, descripcion, direccion, whatsapp, imagenUrl, promocion;
  final Color colorTema;
  final bool isAbierto; 

  const DetalleRestaurantePage({
    super.key, required this.idRestaurante, required this.nombre, required this.colorTema,
    required this.tituloGigante, required this.descripcion, required this.direccion,
    required this.whatsapp, required this.imagenUrl, required this.promocion, required this.isAbierto,
  });

  @override
  State<DetalleRestaurantePage> createState() => _DetalleRestaurantePageState();
}

class _DetalleRestaurantePageState extends State<DetalleRestaurantePage> {
  bool _isFollowing = false;
  Map<String, Map<String, dynamic>> _carrito = {};
  late Stream<QuerySnapshot> _menuStream;

  @override
  void initState() {
    super.initState();
    _verificarSiSigue(); 
    _menuStream = FirebaseFirestore.instance.collection('platillos').where('id_restaurante', isEqualTo: widget.idRestaurante).snapshots();
  }

  void _verificarSiSigue() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('restaurantes').doc(widget.idRestaurante).get();
    if (doc.exists && mounted && ((doc.data() as Map<String, dynamic>)['seguidores'] ?? []).contains(uid)) {
      setState(() => _isFollowing = true);
    }
  }

  void _toggleSeguir() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isFollowing = !_isFollowing);

    DocumentReference ref = FirebaseFirestore.instance.collection('restaurantes').doc(widget.idRestaurante);
    try {
      if (_isFollowing) {
        await ref.update({'seguidores': FieldValue.arrayUnion([uid])});
        await FirebaseFirestore.instance.collection('notificaciones').add({
          'restauranteId': widget.idRestaurante, 'clienteId': uid, 'titulo': '¡Nuevo Seguidor! 🎉',
          'mensaje': 'Alguien nuevo sigue tu restaurante.', 'tipo': 'nuevo_seguidor', 'leida': false, 'fecha': FieldValue.serverTimestamp(),
        });
      } else {
        await ref.update({'seguidores': FieldValue.arrayRemove([uid])});
      }
    } catch (e) { setState(() => _isFollowing = !_isFollowing); }
  }

  void _hacerPedido() async {
    if (!widget.isAbierto || widget.whatsapp.isEmpty) return; 

    String num = widget.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    if (num.length == 10) num = '52$num';

    String mensaje = _carrito.isEmpty 
        ? "Hola, vi su menú en DeLaZona y me gustaría hacer una consulta."
        : "Hola, me gustaría hacer el siguiente pedido:\n\n";

    if (_carrito.isNotEmpty) {
      double total = 0;
      _carrito.forEach((platillo, info) {
        total += (info['cantidad'] * info['precio']);
        mensaje += "• ${info['cantidad']} x $platillo (\$${info['precio']})\n";
      });
      mensaje += "\nTotal estimado: \$${total.toStringAsFixed(2)}\n\nQuedo a la espera de confirmación.";
    }

    try {
      FirebaseFirestore.instance.collection('restaurantes').doc(widget.idRestaurante).set({'clics_whatsapp': FieldValue.increment(1)}, SetOptions(merge: true));
      await launchUrl(Uri.parse("https://wa.me/$num?text=${Uri.encodeComponent(mensaje)}"), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al abrir WhatsApp.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              HeaderDetalleRestaurante(imagenUrl: widget.imagenUrl, colorTema: widget.colorTema, tituloGigante: widget.tituloGigante),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoDetalleRestaurante(
                        nombre: widget.nombre, descripcion: widget.descripcion, direccion: widget.direccion, promocion: widget.promocion, 
                        isAbierto: widget.isAbierto, isFollowing: _isFollowing, onToggleSeguir: _toggleSeguir
                      ),
                      const SizedBox(height: 40),
                      const Text('Menú Completo', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFF0F172A))),
                      const SizedBox(height: 10),
                      _buildMenuStream(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          BotonPedidoRestaurante(
            totalItems: _carrito.values.fold(0, (sum, i) => sum + (i['cantidad'] as int)), 
            isAbierto: widget.isAbierto, tieneWhatsapp: widget.whatsapp.isNotEmpty, onHacerPedido: _hacerPedido
          ),
        ],
      ),
    );
  }

  // El Stream del Menú se queda aquí porque maneja el estado del carrito
  Widget _buildMenuStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: _menuStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Menú no disponible.', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold))));

        Map<String, List<QueryDocumentSnapshot>> categoriasMap = {};
        for (var doc in snapshot.data!.docs) categoriasMap.putIfAbsent((doc.data() as Map)['categoria']?.toString().trim() ?? 'Otros', () => []).add(doc);

        final orden = ['Entradas y Aperitivos', 'Platos Fuertes', 'Desayunos', 'Bebidas', 'Postres', 'Snacks y Botanas', 'Guarniciones o Extras', 'Especialidades', 'Otros'];
        List<String> categorias = categoriasMap.keys.toList()..sort((a, b) => (orden.indexOf(a) == -1 ? 999 : orden.indexOf(a)).compareTo(orden.indexOf(b) == -1 ? 999 : orden.indexOf(b)));

        return ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero, itemCount: categorias.length,
          itemBuilder: (context, index) {
            String cat = categorias[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 24, bottom: 16, left: 8), child: Text(cat.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5))),
                ...categoriasMap[cat]!.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  String nombre = data['nombre'] ?? 'Platillo';
                  int cant = _carrito.containsKey(nombre) ? _carrito[nombre]!['cantidad'] : 0;

                  return TarjetaPlatillo(
                    data: data, nombrePlatillo: nombre, cantidadActual: cant, colorTema: widget.colorTema, isAbierto: widget.isAbierto,
                    onAdd: () => setState(() => _carrito[nombre] = {'cantidad': cant + 1, 'precio': data['precio']}),
                    onRemove: () => setState(() { if (cant > 1) _carrito[nombre]!['cantidad'] = cant - 1; else _carrito.remove(nombre); }),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}