import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'perfil_restaurante_page.dart';
import 'menu_restaurante_page.dart';
import 'publicar_oferta_page.dart';

// --- IMPORTAMOS TODOS TUS WIDGETS ---
import '../../widgets/restaurante/boton_navegacion_panel.dart';
import '../../widgets/restaurante/cabecera_perfil_restaurante.dart';
import '../../widgets/restaurante/interruptor_apertura.dart';
import '../../widgets/restaurante/panel_estadisticas.dart';

class PanelRestaurantePage extends StatefulWidget {
  const PanelRestaurantePage({super.key});

  @override
  State<PanelRestaurantePage> createState() => _PanelRestaurantePageState();
}

class _PanelRestaurantePageState extends State<PanelRestaurantePage> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

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
          await FirebaseFirestore.instance.collection('restaurantes').doc(_uid).set({'fcm_token': token}, SetOptions(merge: true));
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
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('restaurantes').doc(_uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFF26B2A)));
                  }

                  var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  
                  // Aquí simplemente acomodamos nuestros bloques visuales
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
                          onChanged: (val) => FirebaseFirestore.instance.collection('restaurantes').doc(_uid).update({'is_abierto': val}),
                        ),
                        const SizedBox(height: 32),
                        PanelEstadisticas(
                          totalSeguidores: (data['seguidores'] ?? []).length.toString(),
                          totalWhatsApps: (data['clics_whatsapp'] ?? 0).toString(),
                        ),
                        const SizedBox(height: 40),
                        
                        // Botones de Navegación
                        BotonNavegacionPanel(titulo: 'Gestionar Menú', subtitulo: 'PLATILLOS Y PRECIOS', icono: Icons.local_pizza_outlined, colorIcono: const Color(0xFFF26B2A), destino: const MenuRestaurantePage()),
                        const SizedBox(height: 20),
                        BotonNavegacionPanel(titulo: 'Publicar Oferta', subtitulo: 'PROMO RELÁMPAGO', icono: Icons.local_offer_outlined, colorIcono: Colors.blue.shade400, destino: const PublicarOfertaPage()),
                      ],
                    ),
                  );
                }
              ),
            ),
            
            // Botón de Cerrar Sesión
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 10),
              child: TextButton.icon(
                onPressed: () => FirebaseAuth.instance.signOut(),
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