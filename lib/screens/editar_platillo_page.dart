import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditarPlatilloPage extends StatefulWidget {
  final String idPlatillo;
  final Map<String, dynamic> datosActuales;

  const EditarPlatilloPage({
    super.key, 
    required this.idPlatillo, 
    required this.datosActuales
  });

  @override
  State<EditarPlatilloPage> createState() => _EditarPlatilloPageState();
}

class _EditarPlatilloPageState extends State<EditarPlatilloPage> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _descripcionCtrl;
  
  File? _nuevaFoto;
  String _fotoUrlExistente = '';
  bool _isLoading = false;

  final Color orangeColor = const Color(0xFFF26B2A);
  final Color darkBlue = const Color(0xFF0F172A);
  final Color bgColor = const Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.datosActuales['nombre']);
    _precioCtrl = TextEditingController(text: widget.datosActuales['precio'].toString());
    _descripcionCtrl = TextEditingController(text: widget.datosActuales['descripcion']);
    _fotoUrlExistente = widget.datosActuales['foto_url'] ?? '';
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _nuevaFoto = File(pickedFile.path));
    }
  }

  Future<void> _guardarCambios() async {
    if (_nombreCtrl.text.isEmpty || _precioCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre y precio obligatorios'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String urlFinal = _fotoUrlExistente;
      
      if (_nuevaFoto != null) {
        String uidUsuario = widget.datosActuales['id_restaurante'];
        final storageRef = FirebaseStorage.instance.ref().child('fotos_platillos').child('$uidUsuario-${widget.idPlatillo}.jpg');
        await storageRef.putFile(_nuevaFoto!);
        urlFinal = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('platillos').doc(widget.idPlatillo).update({
        'nombre': _nombreCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
        'precio': double.parse(_precioCtrl.text.trim()), 
        'foto_url': urlFinal,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Platillo actualizado'), backgroundColor: Colors.green));
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
        title: Text('Editar Platillo', style: TextStyle(color: darkBlue, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 26)),
        centerTitle: false,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: darkBlue))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- FOTO DEL PLATILLO GIGANTE ---
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 160, height: 160, // Hecho más grande
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(45), // Bordes más redondos
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                          image: _nuevaFoto != null 
                            ? DecorationImage(image: FileImage(_nuevaFoto!), fit: BoxFit.cover) 
                            : (_fotoUrlExistente.isNotEmpty ? DecorationImage(image: NetworkImage(_fotoUrlExistente), fit: BoxFit.cover) : null),
                        ),
                        child: (_nuevaFoto == null && _fotoUrlExistente.isEmpty) 
                          ? const Center(child: Text('🌮', style: TextStyle(fontSize: 50))) 
                          : null,
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

                // --- CAMPOS DE TEXTO ---
                _buildLabel('NOMBRE DEL PLATILLO'),
                _buildTextField(_nombreCtrl, Icons.restaurant),
                
                const SizedBox(height: 20),
                _buildLabel('PRECIO (\$)'),
                _buildTextField(_precioCtrl, Icons.attach_money, isNumber: true),
                
                const SizedBox(height: 20),
                _buildLabel('DESCRIPCIÓN'),
                _buildTextField(_descripcionCtrl, Icons.notes_rounded, maxLines: 4),
              ],
            ),
          ),
      
      // --- BOTÓN GIGANTE ANCLADO ABAJO ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
          child: SizedBox(
            width: double.infinity,
            height: 65, // Botón más grueso
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _guardarCambios,
              icon: const Icon(Icons.check, color: Colors.white, size: 24),
              label: const Text('GUARDAR CAMBIOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.0, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), // Más redondo
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

  Widget _buildTextField(TextEditingController controller, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16), // Letra más grande
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Icon(icon, color: const Color(0xFFF26B2A), size: 24),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22), // Input más alto
        ),
      ),
    );
  }
}