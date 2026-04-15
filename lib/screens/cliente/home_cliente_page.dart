import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detalle_restaurante_page.dart';
import '../../widgets/buscador_cliente.dart';
import '../../widgets/tarjeta_restaurante.dart';

class HomeClientePage extends StatefulWidget {
  const HomeClientePage({super.key});

  @override
  State<HomeClientePage> createState() => _HomeClientePageState();
}

class _HomeClientePageState extends State<HomeClientePage> {
  final Color _primaryOrange = const Color(0xFFF97316);
  final Color _darkBlue = const Color(0xFF0F172A);
  
  String _textoBusqueda = "";

  final List<Color> _cardColors = [
    Colors.green.shade500, Colors.red.shade500, Colors.blue.shade500,
    Colors.purple.shade500, Colors.orange.shade500,
  ];

  // ==========================================================
  // 1. MÉTODO PRINCIPAL (¡Mira qué limpio quedó!)
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildBienvenida(),
            _buildListaRestaurantes(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // 2. MINI-FUNCIONES DE INTERFAZ (Secciones de la pantalla)
  // ==========================================================

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: Colors.white, pinned: true, elevation: 0, toolbarHeight: 80,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Inter', fontStyle: FontStyle.italic),
          children: [
            const TextSpan(text: 'Restaurantes en ', style: TextStyle(color: Colors.black87)),
            TextSpan(text: 'DeLaZona', style: TextStyle(color: _primaryOrange)),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(14)),
            child: IconButton(
              icon: Icon(Icons.logout_rounded, color: Colors.red.shade400, size: 20),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBienvenida() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Text('¡Hola! ¿Qué se te antoja hoy?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: _darkBlue, height: 1.1)),
            const SizedBox(height: 24),
            BuscadorCliente(onChanged: (v) => setState(() => _textoBusqueda = v.toLowerCase())),
            const SizedBox(height: 32),
            Text(_textoBusqueda.isEmpty ? 'Restaurantes Disponibles' : 'Resultados de búsqueda', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: _darkBlue)),
          ],
        ),
      ),
    );
  }

  Widget _buildListaRestaurantes() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('restaurantes').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return _buildMensajeVacio('Aún no hay restaurantes :(');

        // Lógica de filtrado
        var filtrados = snapshot.data!.docs.where((doc) {
          var d = doc.data() as Map<String, dynamic>;
          if (d['isVisible'] == false) return false;
          if (_textoBusqueda.isEmpty) return true;
          return (d['nombre_restaurante']?.toString().toLowerCase().contains(_textoBusqueda) ?? false) ||
                 (d['descripcion']?.toString().toLowerCase().contains(_textoBusqueda) ?? false);
        }).toList();

        if (filtrados.isEmpty) return _buildMensajeVacio('No encontramos "$_textoBusqueda"', icon: Icons.search_off_rounded);

        // Construcción de la lista
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, i) {
              var data = filtrados[i].data() as Map<String, dynamic>;
              String nombre = data['nombre_restaurante'] ?? 'Restaurante';
              String promo = _validarPromo(data);
              Color color = _cardColors[i % _cardColors.length];

              return TarjetaRestaurante(
                nombre: nombre, descripcion: data['descripcion'] ?? 'Deliciosa comida local',
                imagenUrl: data['foto_perfil'] ?? data['imagen_perfil'] ?? '',
                tituloGigante: nombre.split(' ')[0].toUpperCase(), colorTema: color,
                isAbierto: data['is_abierto'] ?? true, promocion: promo,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleRestaurantePage(
                  idRestaurante: filtrados[i].id, nombre: nombre, colorTema: color,
                  tituloGigante: nombre.split(' ')[0].toUpperCase(), descripcion: data['descripcion'] ?? '',
                  direccion: data['direccion'] ?? '', whatsapp: data['whatsapp'] ?? '',
                  imagenUrl: data['foto_perfil'] ?? data['imagen_perfil'] ?? '', promocion: promo, isAbierto: data['is_abierto'] ?? true,
                ))),
              );
            }, childCount: filtrados.length),
          ),
        );
      },
    );
  }

  // ==========================================================
  // 3. HELPERS (Funciones de apoyo para que la lista no crezca)
  // ==========================================================

  // Valida que la fecha de la promo sea correcta
  String _validarPromo(Map<String, dynamic> data) {
    String p = data['promocion'] ?? data['promociones'] ?? data['oferta'] ?? '';
    Timestamp? fIni = data['promocion_inicio'];
    Timestamp? fFin = data['promocion_fin'];
    
    if (p.isNotEmpty && fIni != null && fFin != null) {
      DateTime hoy = DateTime.now(), ini = fIni.toDate(), fin = fFin.toDate();
      if (hoy.isBefore(DateTime(ini.year, ini.month, ini.day)) || hoy.isAfter(DateTime(fin.year, fin.month, fin.day, 23, 59, 59))) {
        return ''; 
      }
    }
    return p;
  }

  // Dibuja la pantalla cuando no hay resultados
  Widget _buildMensajeVacio(String texto, {IconData? icon}) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 60, color: Colors.grey.shade300), const SizedBox(height: 16)],
            Text(texto, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }
}