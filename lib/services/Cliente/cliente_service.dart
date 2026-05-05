import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. OBTENER FLUJO DE RESTAURANTES 
  Stream<List<Map<String, dynamic>>> streamRestaurantes() {
    return _db.collection('restaurantes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
                data['id'] = doc.id; 
                data['promocion_activa'] = _validarPromo(data);
        
        return data;
      }).toList();
    });
  }

  // 2. LÓGICA DE VALIDACIÓN DE FECHAS DE PROMOCIÓN
  String _validarPromo(Map<String, dynamic> data) {
    String p = data['promocion'] ?? data['promociones'] ?? data['oferta'] ?? '';
    Timestamp? fIni = data['promocion_inicio'];
    Timestamp? fFin = data['promocion_fin'];
    
    if (p.isNotEmpty && fIni != null && fFin != null) {
      DateTime hoy = DateTime.now();
      DateTime ini = fIni.toDate();
      DateTime fin = fFin.toDate();
      //se quita la promocion
      if (hoy.isBefore(DateTime(ini.year, ini.month, ini.day)) || 
          hoy.isAfter(DateTime(fin.year, fin.month, fin.day, 23, 59, 59))) {
        return ''; 
      }
    }
    return p;
  }

  // 3. OBTENER MENÚ DEL RESTAURANTE
  Stream<List<Map<String, dynamic>>> streamMenuRestaurante(String idRestaurante) {
    return _db.collection('platillos').where('id_restaurante', isEqualTo: idRestaurante).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  // 4. VERIFICAR SI EL CLIENTE SIGUE AL RESTAURANTE
  Future<bool> verificarSiSigue(String idRestaurante, String uid) async {
    DocumentSnapshot doc = await _db.collection('restaurantes').doc(idRestaurante).get();
    if (doc.exists) {
      List seguidores = (doc.data() as Map<String, dynamic>)['seguidores'] ?? [];
      return seguidores.contains(uid);
    }
    return false;
  }

  // 5. SEGUIR / DEJAR DE SEGUIR AL RESTAURANTE
  Future<void> toggleSeguir(String idRestaurante, String uid, bool currentlyFollowing) async {
    DocumentReference ref = _db.collection('restaurantes').doc(idRestaurante);
    
    if (currentlyFollowing) {
      // Dejar de seguir
      await ref.update({'seguidores': FieldValue.arrayRemove([uid])});
    } else {
      // Seguir y enviar notificación
      await ref.update({'seguidores': FieldValue.arrayUnion([uid])});
      await _db.collection('notificaciones').add({
        'restauranteId': idRestaurante, 
        'clienteId': uid, 
        'titulo': '¡Nuevo Seguidor! 🎉',
        'mensaje': 'Alguien nuevo sigue tu restaurante.', 
        'tipo': 'nuevo_seguidor', 
        'leida': false, 
        'fecha': FieldValue.serverTimestamp(),
      });
    }
  }

  // 6. REGISTRAR ESTADÍSTICA DE WHATSAPP
  Future<void> registrarClicWhatsapp(String idRestaurante) async {
    await _db.collection('restaurantes').doc(idRestaurante).set({
      'clics_whatsapp': FieldValue.increment(1)
    }, SetOptions(merge: true));
  }
}