import 'package:flutter/material.dart';

// --- IMPORTAMOS WIDGETS Y PANTALLAS ---
import 'agregar_platillo_page.dart';
import 'editar_platillo_page.dart';
import '../../widgets/restaurante/dialogo_borrar_platillo.dart';
import '../../widgets/restaurante/tarjeta_platillo_admin.dart';

// --- IMPORTAMOS NUESTROS SERVICIOS ---
import '../../services/auth_service.dart';
import '../../services/Restaurante/platillos_service.dart';

class MenuRestaurantePage extends StatefulWidget {
  const MenuRestaurantePage({super.key});

  @override
  State<MenuRestaurantePage> createState() => _MenuRestaurantePageState();
}

class _MenuRestaurantePageState extends State<MenuRestaurantePage> {
  // Obtenemos el UID desde nuestro servicio, no desde FirebaseAuth directo
  final String _uid = AuthService().usuarioActual!.uid; 
  final PlatillosService _platillosService = PlatillosService(); 
  
  final Color _orangeColor = const Color(0xFFF26B2A);
  final Color _darkBlue = const Color(0xFF0F172A);

  // 1. LÓGICA DE BASE DE DATOS (Usando el Servicio)
  Future<void> _borrarPlatillo(String idPlatillo, String nombrePlatillo) async {
    bool confirmar = await showDialog(
      context: context, 
      builder: (context) => DialogoBorrarPlatillo(nombrePlatillo: nombrePlatillo)
    ) ?? false;

    if (confirmar) {
      await _platillosService.eliminarPlatillo(idPlatillo);
    }
  }

  // 2. INTERFAZ GRÁFICA (UI)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // <-- AHORA USAMOS EL STREAM LIMPIO DEL SERVICIO
        stream: _platillosService.streamPlatillos(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: _orangeColor));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text('Aún no tienes platillos', style: TextStyle(color: Colors.grey.shade400, fontSize: 18, fontWeight: FontWeight.bold)));

          // Agrupación y Ordenamiento usando mapas nativos de Dart
          Map<String, List<Map<String, dynamic>>> platillosAgrupados = {};
          for (var data in snapshot.data!) {
            String categoria = data['categoria']?.toString().trim() ?? 'Otros';
            platillosAgrupados.putIfAbsent(categoria.isEmpty ? 'Otros' : categoria, () => []).add(data);
          }

          final orden = ['Entradas y Aperitivos', 'Platos Fuertes', 'Desayunos', 'Bebidas', 'Postres', 'Snacks y Botanas', 'Guarniciones o Extras', 'Especialidades', 'Otros'];
          List<String> categorias = platillosAgrupados.keys.toList()
            ..sort((a, b) => (orden.indexOf(a) == -1 ? 999 : orden.indexOf(a)).compareTo(orden.indexOf(b) == -1 ? 999 : orden.indexOf(b)));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              String categoria = categorias[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 12, left: 8),
                    child: Text(categoria.toUpperCase(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.5)),
                  ),
                  ...platillosAgrupados[categoria]!.map((data) {
                    return TarjetaPlatilloAdmin(
                      platillo: data,
                      // Usamos data['id'] que inyectamos desde el servicio
                      onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditarPlatilloPage(idPlatillo: data['id'], datosActuales: data))),
                      onDelete: () => _borrarPlatillo(data['id'], data['nombre'] ?? 'este platillo'),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF8F9FA), elevation: 0, toolbarHeight: 80,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
        child: Container(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 2)), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.blueGrey, size: 22), onPressed: () => Navigator.pop(context))),
      ),
      title: Text('Mi Menú', style: TextStyle(color: _darkBlue, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 26)), centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24.0, top: 12, bottom: 12),
          child: Container(
            width: 55, decoration: BoxDecoration(color: _orangeColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: _orangeColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
            child: IconButton(icon: const Icon(Icons.add, color: Colors.white, size: 28), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AgregarPlatilloPage()))),
          ),
        )
      ],
    );
  }
}