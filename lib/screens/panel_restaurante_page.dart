import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'login_page.dart';
import 'perfil_restaurante_page.dart';
import 'menu_restaurante_page.dart';
import 'publicar_oferta_page.dart';

class PanelRestaurantePage extends StatefulWidget {
  const PanelRestaurantePage({super.key});

  @override
  State<PanelRestaurantePage> createState() => _PanelRestaurantePageState();
}

class _PanelRestaurantePageState extends State<PanelRestaurantePage> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  final Color orangeColor = const Color(0xFFF26B2A);
  final Color darkBlue = const Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _configurarNotificacionesPush(); 
  }

  // NOTIFICACIONES PUSH (Para que sigan llegando al celular)
  Future<void> _configurarNotificacionesPush() async {
    try {
      var status = await Permission.notification.status;
      if (status.isDenied) {
        status = await Permission.notification.request();
      }

      if (status.isGranted) {
        debugPrint('✅ Permiso concedido por el usuario');
        
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        
        String? token = await messaging.getToken();
        
        if (token != null) {
          debugPrint('🔥 Mi FCM Token es: $token');
          await FirebaseFirestore.instance.collection('restaurantes').doc(_uid).set({
            'fcm_token': token,
          }, SetOptions(merge: true));
        }
      } else {
        debugPrint('❌ El usuario rechazó el permiso');
      }
    } catch (e) {
      debugPrint("Error configurando Push: $e");
    }
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
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
                  
                  String nombre = "Cargando...";
                  String fotoPerfil = "";
                  bool isAbierto = true; 
                  String totalSeguidores = "0";
                  String totalWhatsApps = "0";

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    nombre = data['nombre_restaurante'] ?? 'Mi Restaurante';
                    fotoPerfil = data['foto_perfil'] ?? '';
                    isAbierto = data['is_abierto'] ?? true; 
                    List<dynamic> seguidores = data['seguidores'] ?? [];
                    totalSeguidores = seguidores.length.toString();
                    totalWhatsApps = (data['clics_whatsapp'] ?? 0).toString();
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0), 
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60, height: 60, 
                              decoration: BoxDecoration(
                                color: orangeColor, 
                                shape: BoxShape.circle, 
                                boxShadow: [BoxShadow(color: orangeColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                              ),
                              child: fotoPerfil.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        fotoPerfil,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Center(child: Text('🔥', style: TextStyle(fontSize: 30))),
                                      ),
                                    )
                                  : const Center(child: Text('🔥', style: TextStyle(fontSize: 30))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: Color(0xFF0F172A))),
                                  const SizedBox(height: 2),
                                  const Text('ADMINISTRADOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.5)),
                                ],
                              ),
                            ),
                            
                            // 🔥 Aquí estaba la campana, ahora solo está el botón de ajustes 🔥
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilRestaurantePage())),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.grey.shade200)),
                                child: Icon(Icons.settings_outlined, color: Colors.grey.shade600, size: 24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(color: isAbierto ? const Color(0xFFE8F8F0) : Colors.red.shade50, borderRadius: BorderRadius.circular(35)),
                          child: Row(
                            children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(color: isAbierto ? Colors.green : Colors.red, shape: BoxShape.circle)),
                              const SizedBox(width: 14),
                              Text(isAbierto ? 'Abierto' : 'Cerrado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, color: isAbierto ? Colors.green.shade800 : Colors.red.shade800)),
                              const Spacer(),
                              Switch(
                                value: isAbierto, 
                                activeColor: Colors.green, 
                                onChanged: (val) {
                                  FirebaseFirestore.instance.collection('restaurantes').doc(_uid).update({
                                    'is_abierto': val
                                  });
                                }
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: darkBlue,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [BoxShadow(color: darkBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('ACTIVIDAD DE HOY', style: TextStyle(color: orangeColor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                                  Icon(Icons.trending_up, color: orangeColor, size: 20),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: _buildStatItem(totalSeguidores, 'SEGUIDORES')),
                                  const SizedBox(width: 20),
                                  Expanded(child: _buildStatItem(totalWhatsApps, 'WHATSAPPS')),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        _buildNavButton(
                          title: 'Gestionar Menú', 
                          subtitle: 'PLATILLOS Y PRECIOS', 
                          icon: Icons.local_pizza_outlined, 
                          iconColor: orangeColor,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MenuRestaurantePage()))
                        ),
                        const SizedBox(height: 20),
                        
                        _buildNavButton(
                          title: 'Publicar Oferta', 
                          subtitle: 'PROMO RELÁMPAGO', 
                          icon: Icons.local_offer_outlined, 
                          iconColor: Colors.blue.shade400,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PublicarOfertaPage()))
                        ),
                      ],
                    ),
                  );
                }
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 10),
              child: TextButton.icon(
                onPressed: _cerrarSesion,
                icon: Icon(Icons.logout, color: Colors.grey.shade400, size: 20),
                label: Text('CERRAR SESIÓN', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, letterSpacing: 2.0, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        ],
      ),
    );
  }

  Widget _buildNavButton({required String title, required String subtitle, required IconData icon, required Color iconColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade300, letterSpacing: 1.5)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 20),
          ],
        ),
      ),
    );
  }
}