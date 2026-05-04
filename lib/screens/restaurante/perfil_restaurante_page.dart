import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/restaurante/campo_formulario.dart';
import '../../widgets/restaurante/etiqueta_formulario.dart';
import '../../widgets/restaurante/selector_imagen_platillo.dart'; // ¡Lo reciclamos para el perfil!

class PerfilRestaurantePage extends StatefulWidget {
  const PerfilRestaurantePage({super.key});

  @override
  State<PerfilRestaurantePage> createState() => _PerfilRestaurantePageState();
}

class _PerfilRestaurantePageState extends State<PerfilRestaurantePage> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoading = true;
  String _fotoUrl = '';
  File? _nuevaFoto;

  final _nombreCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  final Color _orangeColor = const Color(0xFFF26B2A);
  final Color _darkBlue = const Color(0xFF0F172A);
  final Color _bgColor = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // 1. LÓGICA DE BASE DE DATOS Y FOTOS

  Future<void> _cargarDatos() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('restaurantes').doc(_uid).get();
      if (doc.exists && mounted) {
        setState(() {
          var data = doc.data() as Map<String, dynamic>;
          _nombreCtrl.text = data['nombre_restaurante'] ?? '';
          _descripcionCtrl.text = data['descripcion'] ?? '';
          _whatsappCtrl.text = data['whatsapp'] ?? '';
          _direccionCtrl.text = data['direccion'] ?? '';
          _fotoUrl = data['foto_perfil'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarOpcionesDeFoto() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Actualizar foto de perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _darkBlue)),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle), child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFF26B2A))),
                  title: const Text('Tomar foto con la Cámara', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () { Navigator.pop(context); _seleccionarFoto(ImageSource.camera); },
                ),
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle), child: const Icon(Icons.photo_library_rounded, color: Colors.blue)),
                  title: const Text('Elegir de la Galería', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () { Navigator.pop(context); _seleccionarFoto(ImageSource.gallery); },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Future<void> _seleccionarFoto(ImageSource origen) async {
    final pickedFile = await ImagePicker().pickImage(source: origen, imageQuality: 70);
    if (pickedFile != null) setState(() => _nuevaFoto = File(pickedFile.path));
  }

  Future<void> _guardarPerfil() async {
    setState(() => _isLoading = true);
    try {
      String urlFinal = _fotoUrl;

      if (_nuevaFoto != null) {
        final storageRef = FirebaseStorage.instance.ref().child('perfiles_restaurantes').child('$_uid.jpg');
        await storageRef.putFile(_nuevaFoto!);
        urlFinal = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('restaurantes').doc(_uid).update({
        'nombre_restaurante': _nombreCtrl.text.trim(),
        'whatsapp': _whatsappCtrl.text.trim(),
        'direccion': _direccionCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
        'foto_perfil': urlFinal,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil guardado con éxito'), backgroundColor: Colors.green));
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. INTERFAZ GRÁFICA (UI)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor, elevation: 0, toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
          child: Container(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 2)), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.blueGrey, size: 22), onPressed: () => Navigator.pop(context))),
        ),
        title: Text('Perfil del Negocio', style: TextStyle(color: _darkBlue, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 26)), centerTitle: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _orangeColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 Reutilizamos el widget de imagen 🔥
                  SelectorImagenPlatillo(
                    imagenFila: _nuevaFoto, 
                    imageUrl: _fotoUrl, 
                    onTapCamara: _mostrarOpcionesDeFoto
                  ),
                  const SizedBox(height: 40),

                  // 🔥 Reutilizamos los campos de formulario 🔥
                  const EtiquetaFormulario(texto: 'NOMBRE DEL LOCAL'),
                  CampoFormulario(controlador: _nombreCtrl, hint: 'Ej. Taquería El Paisa', icono: Icons.storefront),
                  
                  const SizedBox(height: 20),
                  const EtiquetaFormulario(texto: 'WHATSAPP DE PEDIDOS'),
                  CampoFormulario(controlador: _whatsappCtrl, hint: 'Ej. 9931234567', icono: Icons.phone_outlined, isPhone: true),
                  
                  const SizedBox(height: 20),
                  const EtiquetaFormulario(texto: 'DIRECCIÓN'),
                  CampoFormulario(controlador: _direccionCtrl, hint: 'Ej. Centro, calle 1...', icono: Icons.location_on_outlined),
                  
                  const SizedBox(height: 20),
                  const EtiquetaFormulario(texto: 'DESCRIPCIÓN CORTA'),
                  CampoFormulario(controlador: _descripcionCtrl, hint: 'Breve descripción de tu menú...', icono: Icons.notes_rounded, maxLines: 4),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
          child: SizedBox(
            width: double.infinity, height: 65,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _guardarPerfil,
              icon: const Icon(Icons.check, color: Colors.white, size: 24),
              label: const Text('GUARDAR PERFIL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.0, fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: _orangeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0),
            ),
          ),
        ),
      ),
    );
  }
}