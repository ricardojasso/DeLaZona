import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
// Eliminamos el import de permission_handler de aquí ya que no lo usaremos al inicio

import 'firebase_options.dart'; 
import 'screens/login_page.dart';
import 'screens/panel_restaurante_page.dart';
import 'screens/home_cliente_page.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("📦 Mensaje en segundo plano: ${message.notification?.title}");
}

// --- Función para guardar el Token en Firestore ---
Future<void> _guardarTokenEnBaseDeDatos(String uid, String coleccion) async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection(coleccion).doc(uid).set({
        'fcmToken': token,
        'ultimoAcceso': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint("✅ Token guardado en Firebase para el $coleccion con UID: $uid");
    }
  } catch (e) {
    debugPrint("🚨 Error al guardar token: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // 1. Aquí se pide el permiso de NOTIFICACIONES antes de cargar la app (Este sí lo dejamos)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      final tipo = message.data['tipo'];
      final restauranteId = message.data['restauranteId'];
      final usuarioActual = FirebaseAuth.instance.currentUser;

      if (usuarioActual != null && usuarioActual.uid == restauranteId) {
        if (tipo == 'estado_restaurante' || tipo == 'nuevo_platillo' || tipo == 'nueva_promocion') {
          debugPrint("🔇 Notificación ignorada: El dueño no necesita ver sus propios avisos.");
          return; 
        }
      }

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('🔔 ${message.notification!.title}\n${message.notification!.body}'),
          backgroundColor: const Color(0xFFF26B2A),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  });

  runApp(const DeLaZonaApp());
}

class DeLaZonaApp extends StatelessWidget {
  const DeLaZonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey, 
      title: 'DeLaZona',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF26B2A)),
        fontFamily: 'Inter',
      ),
      home: const EnrutadorPrincipal(), 
    );
  }
}

// Convertimos de vuelta a StatelessWidget ya que no necesitamos el initState aquí
class EnrutadorPrincipal extends StatelessWidget {
  const EnrutadorPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFF26B2A))));
        }

        if (snapshot.hasData) {
          final String uid = snapshot.data!.uid;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('restaurantes').doc(uid).get(),
            builder: (context, restauranteSnapshot) {
              if (restauranteSnapshot.connectionState == ConnectionState.waiting) {
                 return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFF26B2A))));
              }

              if (restauranteSnapshot.hasData && restauranteSnapshot.data!.exists) {
                _guardarTokenEnBaseDeDatos(uid, 'restaurantes');
                return const PanelRestaurantePage();
              } else {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('clientes').doc(uid).get(),
                  builder: (context, clienteSnapshot) {
                     if (clienteSnapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFF26B2A))));
                     }
                     if (clienteSnapshot.hasData && clienteSnapshot.data!.exists) {
                        _guardarTokenEnBaseDeDatos(uid, 'clientes');
                        return const HomeClientePage();
                     } else {
                        return const LoginPage(); 
                     }
                  },
                );
              }
            },
          );
        }
        return const LoginPage();
      },
    );
  }
}