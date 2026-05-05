import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; 

// --- IMPORTAMOS NUESTROS SERVICIOS ---
import '../../services/auth_service.dart';
import '../../services/Cliente/cliente_service.dart';

// --- IMPORTAMOS WIDGETS ---
import '../../widgets/cliente/tarjeta_platillo.dart';
import '../../widgets/cliente/header_detalle_restaurante.dart';
import '../../widgets/cliente/info_detalle_restaurante.dart';
import '../../widgets/cliente/boton_pedido_restaurante.dart';

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
  final Map<String, Map<String, dynamic>> _carrito = {}; // Tu carrito intacto
  
  // Instanciamos nuestros servicios
  final ClienteService _clienteService = ClienteService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _verificarSiSigue(); 
  }

  void _verificarSiSigue() async {
    String? uid = _authService.usuarioActual?.uid;
    if (uid == null) return;
    
    // 🔥 MAGIA DEL SERVICIO 🔥
    bool follows = await _clienteService.verificarSiSigue(widget.idRestaurante, uid);
    if (mounted) setState(() => _isFollowing = follows);
  }

  void _toggleSeguir() async {
    String? uid = _authService.usuarioActual?.uid;
    if (uid == null) return;
    
    // Cambiamos el estado visual inmediatamente para que no se sienta lag
    setState(() => _isFollowing = !_isFollowing);

    try {
      // 🔥 MAGIA DEL SERVICIO 🔥
      await _clienteService.toggleSeguir(widget.idRestaurante, uid, !_isFollowing);
    } catch (e) { 
      // Si falla, revertimos el botón
      if (mounted) setState(() => _isFollowing = !_isFollowing); 
    }
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
      // 🔥 MAGIA DEL SERVICIO 🔥
      _clienteService.registrarClicWhatsapp(widget.idRestaurante);
      
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

  Widget _buildMenuStream() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      // 🔥 OBTENEMOS LA LISTA LIMPIA DESDE EL SERVICIO 🔥
      stream: _clienteService.streamMenuRestaurante(widget.idRestaurante),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Menú no disponible.', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold))));

        Map<String, List<Map<String, dynamic>>> categoriasMap = {};
        for (var data in snapshot.data!) {
          categoriasMap.putIfAbsent(data['categoria']?.toString().trim() ?? 'Otros', () => []).add(data);
        }

        final orden = ['Entradas y Aperitivos', 'Platos Fuertes', 'Desayunos', 'Bebidas', 'Postres', 'Snacks y Botanas', 'Guarniciones o Extras', 'Especialidades', 'Otros'];
        List<String> categorias = categoriasMap.keys.toList()..sort((a, b) => (!orden.contains(a) ? 999 : orden.indexOf(a)).compareTo(!orden.contains(b) ? 999 : orden.indexOf(b)));

        return ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero, itemCount: categorias.length,
          itemBuilder: (context, index) {
            String cat = categorias[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(padding: const EdgeInsets.only(top: 24, bottom: 16, left: 8), child: Text(cat.toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.grey.shade400, letterSpacing: 1.5))),
                
                ...categoriasMap[cat]!.map((data) {
                  String nombre = data['nombre'] ?? 'Platillo';
                  int cant = _carrito.containsKey(nombre) ? _carrito[nombre]!['cantidad'] : 0;

                  return TarjetaPlatillo(
                    data: data, nombrePlatillo: nombre, cantidadActual: cant, colorTema: widget.colorTema, isAbierto: widget.isAbierto,
                    onAdd: () => setState(() => _carrito[nombre] = {'cantidad': cant + 1, 'precio': data['precio']}),
                    onRemove: () => setState(() { 
                      if (cant > 1) {
                        _carrito[nombre]!['cantidad'] = cant - 1;
                      } else {
                        _carrito.remove(nombre);
                      } 
                    }),
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