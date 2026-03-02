import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart'; // Asegúrate de tener este archivo generado por Firebase CLI
import 'screens/login_page.dart';
import 'screens/panel_restaurante_page.dart';

void main() async {
  // 1. Asegurarnos de que los widgets estén inicializados antes de Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const DeLaZonaApp());
}

class DeLaZonaApp extends StatelessWidget {
  const DeLaZonaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeLaZona',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF26B2A)),
        fontFamily: 'Inter', // Asegúrate de tener esta fuente en tu pubspec.yaml
      ),
      // 3. En lugar de poner 'home: LoginPage()', usamos el Enrutador
      home: const EnrutadorPrincipal(), 
    );
  }
}

// --- CLASE ENRUTADORA ---
// Esta clase decide a qué pantalla enviar al usuario apenas abre la app
class EnrutadorPrincipal extends StatelessWidget {
  const EnrutadorPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en la sesión de Firebase Auth
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // Mientras Firebase verifica la sesión, mostramos un loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF26B2A)),
            ),
          );
        }

        // Si SI hay un usuario logueado (snapshot.hasData es true)
        if (snapshot.hasData) {
          // Extraemos el UID del usuario logueado
          final String uid = snapshot.data!.uid;

          // Hacemos una comprobación rápida en Firestore para saber si es Cliente o Restaurante
          // (Por ahora, lo mandaremos al panel de restaurante, pero aquí puedes agregar la lógica
          // para mandarlo al de cliente si el UID está en la colección de 'clientes')
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('restaurantes').doc(uid).get(),
            builder: (context, restauranteSnapshot) {
              
              if (restauranteSnapshot.connectionState == ConnectionState.waiting) {
                 return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFFF26B2A)),
                  ),
                );
              }

              // Si existe en la colección de restaurantes, lo mandamos al Panel
              if (restauranteSnapshot.hasData && restauranteSnapshot.data!.exists) {
                return const PanelRestaurantePage();
              } else {
                // Si NO es restaurante, por ahora lo mandamos al login (o al panel de cliente cuando lo tengas)
                // FirebaseAuth.instance.signOut(); // Opcional: Cerrarle la sesión si no encuentra su rol
                return const LoginPage(); 
              }
            },
          );
        }

        // Si NO hay nadie logueado (snapshot.hasData es false), mostramos el Login
        return const LoginPage();
      },
    );
  }
}