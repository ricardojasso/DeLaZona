import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  final Color orangeColor = const Color(0xFFF26B2A);
  final Color darkBlue = const Color(0xFF0F172A);
  final Color bgColor = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('restaurantes').doc(_uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _nombreCtrl.text = doc['nombre_restaurante'] ?? '';
          _descripcionCtrl.text = doc['descripcion'] ?? '';
          
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _whatsappCtrl.text = data.containsKey('whatsapp') ? data['whatsapp'] : '';
          _direccionCtrl.text = data.containsKey('direccion') ? data['direccion'] : '';
          
          _fotoUrl = doc['foto_perfil'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _nuevaFoto = File(pickedFile.path);
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        toolbarHeight: 80, // AppBar más alto
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 2)),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.blueGrey, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text('Perfil del Negocio', style: TextStyle(color: darkBlue, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 26)),
        centerTitle: false,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: orangeColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- FOTO DE PERFIL GIGANTE ---
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 160, height: 160, // Escalado
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(45),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                            image: _nuevaFoto != null 
                              ? DecorationImage(image: FileImage(_nuevaFoto!), fit: BoxFit.cover)
                              : (_fotoUrl.isNotEmpty ? DecorationImage(image: NetworkImage(_fotoUrl), fit: BoxFit.cover) : null),
                          ),
                          child: (_nuevaFoto == null && _fotoUrl.isEmpty) ? const Center(child: Text('🔥', style: TextStyle(fontSize: 50))) : null,
                        ),
                        GestureDetector(
                          onTap: _seleccionarFoto,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: orangeColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: bgColor, width: 3)),
                            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- CAMPOS DE TEXTO ESCALADOS ---
                  _buildLabel('NOMBRE DEL LOCAL'),
                  _buildTextField(_nombreCtrl, Icons.storefront),
                  
                  const SizedBox(height: 20),
                  _buildLabel('WHATSAPP DE PEDIDOS'),
                  _buildTextField(_whatsappCtrl, Icons.phone_outlined, isPhone: true),
                  
                  const SizedBox(height: 20),
                  _buildLabel('DIRECCIÓN'),
                  _buildTextField(_direccionCtrl, Icons.location_on_outlined),
                  
                  const SizedBox(height: 20),
                  _buildLabel('DESCRIPCIÓN CORTA'),
                  _buildTextField(_descripcionCtrl, Icons.notes_rounded, maxLines: 4),
                ],
              ),
            ),
      // --- BOTÓN GIGANTE NARANJA ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
          child: SizedBox(
            width: double.infinity,
            height: 65, // Botón grueso
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _guardarPerfil,
              icon: const Icon(Icons.check, color: Colors.white, size: 24),
              label: const Text('GUARDAR PERFIL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.0, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: orangeColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.blueGrey.shade400, letterSpacing: 2.0)),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, {bool isPhone = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Icon(icon, color: const Color(0xFFF26B2A), size: 24),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        ),
      ),
    );
  }
}