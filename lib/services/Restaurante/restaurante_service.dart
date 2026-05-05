import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RestauranteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

// 1. OBTENER DATOS EN TIEMPO REAL (Traducidos a un Map nativo)
  Stream<Map<String, dynamic>?> streamDatosRestaurante(String uid) {
    return _db.collection('restaurantes').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    });
  }
  // 2. OBTENER DATOS UNA SOLA VEZ (Para cargar el Perfil al abrir la pantalla)
  Future<Map<String, dynamic>?> obtenerDatosPerfil(String uid) async {
    DocumentSnapshot doc = await _db.collection('restaurantes').doc(uid).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // 3. ACTUALIZAR EL PERFIL (Incluye subida de foto)
  Future<void> actualizarPerfil({
    required String uid,
    required String nombre,
    required String descripcion,
    required String whatsapp,
    required String direccion,
    required String fotoUrlExistente,
    File? nuevaFoto,
  }) async {
    String urlFinal = fotoUrlExistente;

    // Si hay foto nueva, la subimos a Storage
    if (nuevaFoto != null) {
      final storageRef = _storage.ref().child('perfiles_restaurantes').child('$uid.jpg');
      await storageRef.putFile(nuevaFoto);
      urlFinal = await storageRef.getDownloadURL();
    }

    await _db.collection('restaurantes').doc(uid).update({
      'nombre_restaurante': nombre,
      'whatsapp': whatsapp,
      'direccion': direccion,
      'descripcion': descripcion,
      'foto_perfil': urlFinal,
    });
  }

  // 4. ABRIR / CERRAR EL LOCAL
  Future<void> cambiarEstadoApertura(String uid, bool isAbierto) async {
    await _db.collection('restaurantes').doc(uid).update({'is_abierto': isAbierto});
  }

  // 5. PUBLICAR UNA OFERTA
  Future<void> publicarOferta({
    required String uid,
    required String titulo,
    required String descripcion,
    required DateTime fechaInicio,
    required DateTime fechaFin,
  }) async {
    await _db.collection('restaurantes').doc(uid).update({
      'promocion': titulo,
      'promocion_descripcion': descripcion,
      'promocion_inicio': Timestamp.fromDate(fechaInicio),
      'promocion_fin': Timestamp.fromDate(fechaFin),
    });
  }

  // 6. ELIMINAR LA OFERTA ACTUAL
  Future<void> eliminarOferta(String uid) async {
    await _db.collection('restaurantes').doc(uid).update({
      'promocion': '',
      'promocion_inicio': FieldValue.delete(),
      'promocion_fin': FieldValue.delete(),
    });
  }

  // 7. GUARDAR TOKEN DE NOTIFICACIONES PUSH
  Future<void> guardarFCMToken(String uid, String token) async {
    await _db.collection('restaurantes').doc(uid).set({'fcm_token': token}, SetOptions(merge: true));
  }
}