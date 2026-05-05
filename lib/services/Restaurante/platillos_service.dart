import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PlatillosService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. OBTENER EL MENÚ 
  Stream<List<Map<String, dynamic>>> streamPlatillos(String uidRestaurante) {
    return _db.collection('platillos')
        .where('id_restaurante', isEqualTo: uidRestaurante)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Inyectamos el ID para usarlo al editar o borrar
        return data;
      }).toList();
    });
  }

  // 2. CREAR UN NUEVO PLATILLO (Incluye subida de imagen)
  Future<void> crearPlatillo({
    required String uidRestaurante,
    required String nombre,
    required String descripcion,
    required double precio,
    required String categoria,
    File? fotoPlatillo,
  }) async {
    String fotoUrl = '';
    String idGenerado = DateTime.now().millisecondsSinceEpoch.toString();

    // Si hay foto, primero la subimos a Storage
    if (fotoPlatillo != null) {
      final storageRef = _storage.ref().child('fotos_platillos').child('$uidRestaurante-$idGenerado.jpg');
      await storageRef.putFile(fotoPlatillo);
      fotoUrl = await storageRef.getDownloadURL();
    }

    // Luego guardamos los datos en Firestore
    await _db.collection('platillos').add({
      'id_restaurante': uidRestaurante,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
      'foto_url': fotoUrl,
      'fecha_creacion': FieldValue.serverTimestamp(),
    });
  }

  // 3. EDITAR UN PLATILLO EXISTENTE
  Future<void> actualizarPlatillo({
    required String idPlatillo,
    required String uidRestaurante,
    required String nombre,
    required String descripcion,
    required double precio,
    required String categoria,
    required String fotoUrlExistente,
    File? nuevaFoto,
  }) async {
    String urlFinal = fotoUrlExistente;

    // Si el usuario eligió una foto nueva, la reemplazamos
    if (nuevaFoto != null) {
      final storageRef = _storage.ref().child('fotos_platillos').child('$uidRestaurante-$idPlatillo.jpg');
      await storageRef.putFile(nuevaFoto);
      urlFinal = await storageRef.getDownloadURL();
    }

    await _db.collection('platillos').doc(idPlatillo).update({
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'categoria': categoria,
      'foto_url': urlFinal,
    });
  }

  // 4. ELIMINAR UN PLATILLO
  Future<void> eliminarPlatillo(String idPlatillo) async {
    await _db.collection('platillos').doc(idPlatillo).delete();
  }
}