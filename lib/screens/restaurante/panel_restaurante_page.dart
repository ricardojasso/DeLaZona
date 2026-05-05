import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/auth_service.dart';
import 'perfil_restaurante_page.dart';
import 'menu_restaurante_page.dart';
import 'publicar_oferta_page.dart';
import '../../widgets/restaurante/boton_navegacion_panel.dart';
import '../../widgets/restaurante/cabecera_perfil_restaurante.dart';
import '../../widgets/restaurante/interruptor_apertura.dart';
import '../../widgets/restaurante/panel_estadisticas.dart';
import '../../services/Restaurante/restaurante_service.dart';

class PanelRestaurantePage extends StatefulWidget {
  const PanelRestaurantePage({super.key});

  @override
  State<PanelRestaurantePage> createState() => _PanelRestaurantePageState();
}

class _PanelRestaurantePageState extends State<PanelRestaurantePage> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  final RestauranteService _restauranteService = RestauranteService();

  @override
  void initState() {
    super.initState();
    _configurarNotificacionesPush(); 
  }

  Future<void> _configurarNotificacionesPush() async {
    try {
      var status = await Permission.notification.status;
      if (status.isDenied) status = await Permission.notification.request();

      if (status.isGranted) {
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _restauranteService.guardarFCMToken(_uid, token);
        }
      }
    } catch (e) {
      debugPrint("Error configurando Push: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<Map<String, dynamic>?>(
                stream: _restauranteService.streamDatosRestaurante(_uid),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFF26B2A)));
                  }

                  var data = snapshot.data!;
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0), 
                    child: Column(
                      children: [
                        CabeceraPerfilRestaurante(
                          nombre: data['nombre_restaurante'] ?? 'Mi Restaurante',
                          fotoPerfil: data['foto_perfil'] ?? '',
                          onAjustesTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilRestaurantePage())),
                        ),
                        const SizedBox(height: 32),
                        
                        InterruptorApertura(
                          isAbierto: data['is_abierto'] ?? true,
                          onChanged: (val) => _restauranteService.cambiarEstadoApertura(_uid, val),
                        ),
                        const SizedBox(height: 32),
                        
                        PanelEstadisticas(
                          totalSeguidores: (data['seguidores'] ?? []).length.toString(),
                          totalWhatsApps: (data['clics_whatsapp'] ?? 0).toString(),
                        ),
                        const SizedBox(height: 40),
                        
                        BotonNavegacionPanel(titulo: 'Gestionar Menú', subtitulo: 'PLATILLOS Y PRECIOS', icono: Icons.local_pizza_outlined, colorIcono: const Color(0xFFF26B2A), destino: const MenuRestaurantePage()),
                        const SizedBox(height: 20),
                        BotonNavegacionPanel(titulo: 'Publicar Oferta', subtitulo: 'PROMO RELÁMPAGO', icono: Icons.local_offer_outlined, colorIcono: Colors.blue.shade400, destino: const PublicarOfertaPage()),
                      ],
                    ),
                  );
                }
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 10),
              child: TextButton.icon(
                onPressed: () => AuthService().cerrarSesion(),
                icon: Icon(Icons.logout, color: Colors.grey.shade400, size: 20),
                label: Text('CERRAR SESIÓN', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, letterSpacing: 2.0, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}