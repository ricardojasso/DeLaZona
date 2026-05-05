import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. OBTENER EL USUARIO ACTUAL
  User? get usuarioActual => _auth.currentUser;

  // 2. ESCUCHAR EL ESTADO DE LA SESIÓN (Si está logueado o no)
  Stream<User?> get estadoAutenticacion => _auth.authStateChanges();

  // 3. INICIAR SESIÓN (Normal)
  Future<UserCredential> iniciarSesion({required String email, required String password}) async {
    return await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );
  }

  // 4. CERRAR SESIÓN
  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  // 5. REGISTRAR UN NUEVO RESTAURANTE (Con base de datos inicial)
  Future<UserCredential> registrarRestaurante({
    required String email,
    required String password,
    required String nombreRestaurante,
  }) async {
    // A. Creamos la cuenta en Firebase Auth
    UserCredential credencial = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // B. Creamos su perfil en blanco en Firestore
    if (credencial.user != null) {
      await _db.collection('restaurantes').doc(credencial.user!.uid).set({
        'correo': email,
        'nombre_restaurante': nombreRestaurante,
        'descripcion': '',
        'direccion': '',
        'whatsapp': '',
        'foto_perfil': '',
        'is_abierto': false, 
        'fecha_registro': FieldValue.serverTimestamp(),
      });
    }

    return credencial;
  }

  // 6. INICIAR SESIÓN Y DETERMINAR ROL (Admin, Restaurante o Cliente)
  Future<Map<String, dynamic>> iniciarSesionYObtenerRol({required String email, required String password}) async {
    UserCredential credencial = await _auth.signInWithEmailAndPassword(email: email, password: password);
    String uid = credencial.user!.uid;

    // A. Verificar si es Admin
    DocumentSnapshot docAdmin = await _db.collection('usuarios_roles').doc(uid).get();
    if (docAdmin.exists && (docAdmin.data() as Map<String, dynamic>)['role'] == 'admin') {
      return {'rol': 'admin', 'nombre': 'Administrador Maestro'};
    }

    // B. Verificar si es Restaurante
    DocumentSnapshot docRest = await _db.collection('restaurantes').doc(uid).get();
    if (docRest.exists) {
      return {'rol': 'restaurante', 'nombre': (docRest.data() as Map<String, dynamic>)['nombre_restaurante'] ?? 'Restaurante'};
    }

    // C. Por defecto asumimos que es Cliente
    return {'rol': 'cliente', 'nombre': 'Cliente'};
  }
  // 7. REGISTRAR UN NUEVO CLIENTE
  Future<UserCredential> registrarCliente({
    required String email,
    required String password,
  }) async {
    // A. Creamos la cuenta en Firebase Auth
    UserCredential credencial = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // B. Creamos su perfil en la colección de clientes
    if (credencial.user != null) {
      await _db.collection('clientes').doc(credencial.user!.uid).set({
        'email': email,
        'rol': 'cliente',
        'fecha_registro': FieldValue.serverTimestamp(),
      });
    }

    return credencial;
}
}
