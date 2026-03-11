import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

class DetalleRestaurantePage extends StatefulWidget {
  final String idRestaurante;
  final String nombre;
  final Color colorTema;
  final String tituloGigante;
  final String descripcion;
  final String direccion;
  final String whatsapp;
  final String imagenUrl; 
  final String promocion; 
  final bool isAbierto; 

  const DetalleRestaurantePage({
    super.key,
    required this.idRestaurante,
    required this.nombre,
    required this.colorTema,
    required this.tituloGigante,
    required this.descripcion,
    required this.direccion,
    required this.whatsapp,
    required this.imagenUrl,
    required this.promocion,
    required this.isAbierto,
  });

  @override
  State<DetalleRestaurantePage> createState() => _DetalleRestaurantePageState();
}

class _DetalleRestaurantePageState extends State<DetalleRestaurantePage> {
  final Color darkBlue = const Color(0xFF0F172A);
  final Color bgColor = const Color(0xFFF8F9FA);
  
  bool _isFollowing = false;
  
  // 🔥 NUEVO: Ahora el carrito guarda la cantidad Y el precio
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
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      List<dynamic> seguidores = data['seguidores'] ?? [];
      
      if (seguidores.contains(uid) && mounted) {
        setState(() {
          _isFollowing = true;
        });
      }
    }
  }

  void _toggleSeguir() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isFollowing = !_isFollowing; 
    });

    DocumentReference docRef = FirebaseFirestore.instance.collection('restaurantes').doc(widget.idRestaurante);

    try {
      if (_isFollowing) {
        await docRef.update({
          'seguidores': FieldValue.arrayUnion([uid])
        });

        await FirebaseFirestore.instance.collection('notificaciones').add({
          'restauranteId': widget.idRestaurante,
          'clienteId': uid, 
          'titulo': '¡Nuevo Seguidor! 🎉',
          'mensaje': 'Alguien nuevo ha comenzado a seguir tu restaurante.',
          'tipo': 'nuevo_seguidor',
          'leida': false,
          'fecha': FieldValue.serverTimestamp(),
        });

      } else {
        await docRef.update({
          'seguidores': FieldValue.arrayRemove([uid])
        });
      }
    } catch (e) {
      setState(() {
        _isFollowing = !_isFollowing;
      });
    }
  }

  void _hacerPedido() async {
    if (!widget.isAbierto) return; 

    if (widget.whatsapp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este restaurante no tiene un número registrado.'), backgroundColor: Colors.red)
      );
      return;
    }

    String numeroLimpio = widget.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeroLimpio.length == 10) {
      numeroLimpio = '52$numeroLimpio';
    }

    String mensaje = "";
    if (_carrito.isEmpty) {
      mensaje = "Hola, vi su menú en DeLaZona y me gustaría hacer una consulta.";
    } else {
      double totalPedido = 0; // 🔥 Calculadora del total
      mensaje = "Hola, me gustaría hacer el siguiente pedido:\n\n";
      
      _carrito.forEach((platillo, info) {
        int cantidad = info['cantidad'];
        double precio = (info['precio'] as num).toDouble();
        double subtotal = cantidad * precio;
        totalPedido += subtotal;
        
        // 🔥 Aquí se agrega el precio individual al mensaje
        mensaje += "• $cantidad x $platillo (\$${precio.toStringAsFixed(2)})\n";
      });
      
      // 🔥 Se agrega el Total a pagar al final
      mensaje += "\nTotal estimado: \$${totalPedido.toStringAsFixed(2)}\n";
      mensaje += "\nQuedo a la espera de la confirmación.";
    }

    Uri url = Uri.parse("https://wa.me/$numeroLimpio?text=${Uri.encodeComponent(mensaje)}");

    try {
      FirebaseFirestore.instance.collection('restaurantes').doc(widget.idRestaurante).set({
        'clics_whatsapp': FieldValue.increment(1)
      }, SetOptions(merge: true));

      bool abierto = await launchUrl(url, mode: LaunchMode.externalApplication);
      
      if (!abierto && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp. Verifica tu conexión.'), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo redirigir. ¿Tienes WhatsApp instalado?'), backgroundColor: Colors.red)
        );
      }
    }
  }

  Widget _buildFallbackHeader() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Text(
          widget.tituloGigante,
          style: TextStyle(fontSize: 65, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.95), fontStyle: FontStyle.italic, letterSpacing: -2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Nueva forma de calcular cuántos items llevamos en el botón de abajo
    int totalItems = _carrito.values.fold(0, (sum, info) => sum + (info['cantidad'] as int));
    bool puedePedir = widget.isAbierto && widget.whatsapp.isNotEmpty;
    
    String textoBoton = "";
    if (!widget.isAbierto) {
      textoBoton = "Restaurante Cerrado";
    } else if (totalItems > 0) {
      textoBoton = "Pedir $totalItems Platillos";
    } else {
      textoBoton = "Hacer Consulta";
    }

    Color colorBoton = widget.isAbierto ? const Color(0xFF25D366) : Colors.grey.shade400;

    return Scaffold(
      backgroundColor: Colors.white, 
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220.0,
                floating: false,
                pinned: true,
                backgroundColor: widget.colorTema,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: widget.colorTema,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
                      boxShadow: [BoxShadow(color: widget.colorTema.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(50)),
                      child: widget.imagenUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.imagenUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                            errorWidget: (context, url, error) => _buildFallbackHeader(),
                          )
                        : _buildFallbackHeader(),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
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
                                Text(widget.nombre, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: darkBlue, height: 1.1)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: widget.isAbierto ? Colors.green.shade50 : Colors.red.shade50, 
                                        borderRadius: BorderRadius.circular(16)
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 10, height: 10,
                                            decoration: BoxDecoration(color: widget.isAbierto ? Colors.green : Colors.red, shape: BoxShape.circle),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            widget.isAbierto ? 'Abierto' : 'Cerrado', 
                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: widget.isAbierto ? Colors.green.shade700 : Colors.red.shade700)
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(widget.descripcion, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _toggleSeguir, 
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                color: _isFollowing ? Colors.red.shade500 : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _isFollowing ? Colors.transparent : Colors.grey.shade200, width: 2),
                                boxShadow: _isFollowing ? [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))] : [],
                              ),
                              child: Icon(
                                _isFollowing ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: _isFollowing ? Colors.white : Colors.grey.shade400,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade100)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DETALLES DEL NEGOCIO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: 1.5)),
                            const SizedBox(height: 16),
                            const Text('DIRECCIÓN:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                            const SizedBox(height: 4),
                            Text(widget.direccion, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                            if (widget.promocion.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Text('OFERTA ESPECIAL:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.orange.shade500, borderRadius: BorderRadius.circular(12)),
                                child: Text(widget.promocion, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      Text('Menú Completo', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: darkBlue)),
                      const SizedBox(height: 10),

                      StreamBuilder<QuerySnapshot>(
                        stream: _menuStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text('Este restaurante aún no ha subido su menú.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            );
                          }

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
                            shrinkWrap: true, 
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: categorias.length,
                            itemBuilder: (context, index) {
                              String nombreCategoria = categorias[index];
                              List<QueryDocumentSnapshot> platillosDeEstaCat = platillosAgrupados[nombreCategoria]!;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24, bottom: 16, left: 8),
                                    child: Text(
                                      nombreCategoria.toUpperCase(),
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5),
                                    ),
                                  ),
                                  
                                  ...platillosDeEstaCat.map((platilloDoc) {
                                    Map<String, dynamic> data = platilloDoc.data() as Map<String, dynamic>;
                                    String fotoUrl = data.containsKey('foto_url') ? data['foto_url'] : '';
                                    String nombrePlatillo = data['nombre'] ?? 'Platillo';
                                    
                                    // 🔥 Extraemos la cantidad desde nuestro nuevo mapa estructurado
                                    int cantidadActual = _carrito.containsKey(nombrePlatillo) ? _carrito[nombrePlatillo]!['cantidad'] : 0;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: cantidadActual > 0 ? widget.colorTema.withOpacity(0.05) : Colors.white,
                                        borderRadius: BorderRadius.circular(24), 
                                        border: Border.all(color: cantidadActual > 0 ? widget.colorTema.withOpacity(0.5) : Colors.grey.shade100),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          if (fotoUrl.isNotEmpty) ...[
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: CachedNetworkImage(
                                                imageUrl: fotoUrl,
                                                width: 75, height: 75, fit: BoxFit.cover,
                                                placeholder: (context, url) => Container(
                                                  width: 75, height: 75, color: Colors.grey.shade100,
                                                  child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF26B2A)))),
                                                ),
                                                errorWidget: (context, url, error) => Container(
                                                  width: 75, height: 75, color: Colors.grey.shade100,
                                                  child: Icon(Icons.fastfood, color: Colors.grey.shade400),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                          ],
                                          
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(nombrePlatillo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                                if (data['descripcion'] != null && data['descripcion'].toString().isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Text(data['descripcion'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                                                ]
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text('\$${data['precio']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkBlue)),
                                              const SizedBox(height: 8),
                                              if (widget.isAbierto) 
                                                Container(
                                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (cantidadActual > 0) {
                                                            setState(() {
                                                              if (cantidadActual > 1) {
                                                                _carrito[nombrePlatillo]!['cantidad'] = cantidadActual - 1;
                                                              } else {
                                                                _carrito.remove(nombrePlatillo);
                                                              }
                                                            });
                                                          }
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.all(6),
                                                          decoration: BoxDecoration(color: cantidadActual > 0 ? Colors.red.shade400 : Colors.grey.shade300, shape: BoxShape.circle),
                                                          child: const Icon(Icons.remove, size: 16, color: Colors.white),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                        child: Text('$cantidadActual', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _carrito[nombrePlatillo] = {
                                                              'cantidad': cantidadActual + 1,
                                                              'precio': data['precio']
                                                            };
                                                          });
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.all(6),
                                                          decoration: BoxDecoration(color: Colors.green.shade500, shape: BoxShape.circle),
                                                          child: const Icon(Icons.add, size: 16, color: Colors.white),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
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
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.white, Colors.white.withOpacity(0.0)]),
              ),
              child: ElevatedButton.icon(
                onPressed: puedePedir ? _hacerPedido : null,
                icon: Icon(widget.isAbierto ? Icons.chat_bubble_rounded : Icons.lock_clock_rounded, color: Colors.white),
                label: Text(textoBoton, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorBoton,
                  disabledBackgroundColor: colorBoton, 
                  minimumSize: const Size(double.infinity, 65),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: widget.isAbierto ? 10 : 0, 
                  shadowColor: colorBoton.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}