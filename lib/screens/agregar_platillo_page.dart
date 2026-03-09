import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AgregarPlatilloPage extends StatefulWidget {
  const AgregarPlatilloPage({super.key});

  @override
  State<AgregarPlatilloPage> createState() => _AgregarPlatilloPageState();
}

class _AgregarPlatilloPageState extends State<AgregarPlatilloPage> {
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  
  // 🔥 NUEVO: Lista de categorías predefinidas MUCHO MÁS GENERALES
  final List<String> _categoriasDisponibles = [
    'Entradas y Aperitivos',
    'Platos Fuertes',
    'Desayunos',
    'Bebidas',
    'Postres',
    'Snacks y Botanas',
    'Guarniciones o Extras',
    'Especialidades',
    'Otros'
  ];
  String _categoriaSeleccionada = 'Platos Fuertes'; // Valor por defecto
  
  File? _fotoPlatillo;
  bool _isLoading = false;

  final Color orangeColor = const Color(0xFFF26B2A);
  final Color darkBlue = const Color(0xFF0F172A);
  final Color bgColor = const Color(0xFFF8F9FA);

  void _mostrarOpcionesDeFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Foto del Platillo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkBlue)),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFFF26B2A)),
                  ),
                  title: const Text('Tomar foto con la Cámara', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarFoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: const Icon(Icons.photo_library_rounded, color: Colors.blue),
                  ),
                  title: const Text('Elegir de la Galería', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    _seleccionarFoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Future<void> _seleccionarFoto(ImageSource origen) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: origen, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _fotoPlatillo = File(pickedFile.path));
    }
  }

  Future<void> _crearPlatillo() async {
    if (_nombreCtrl.text.isEmpty || _precioCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Llena el nombre y el precio'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String uidUsuario = FirebaseAuth.instance.currentUser!.uid;
      String idPlatilloUnico = DateTime.now().millisecondsSinceEpoch.toString(); 
      String fotoUrl = '';
      
      if (_fotoPlatillo != null) {
        final storageRef = FirebaseStorage.instance.ref().child('fotos_platillos').child('$uidUsuario-$idPlatilloUnico.jpg');
        await storageRef.putFile(_fotoPlatillo!);
        fotoUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('platillos').add({
        'id_restaurante': uidUsuario, 
        'nombre': _nombreCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
        'precio': double.parse(_precioCtrl.text.trim()), 
        'categoria': _categoriaSeleccionada, // 🔥 Guardamos la opción elegida de la lista
        'foto_url': fotoUrl,
        'fecha_creacion': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Platillo creado con éxito'), backgroundColor: Colors.green));
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
        toolbarHeight: 80,
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
        title: Text('Añadir Platillo', style: TextStyle(color: darkBlue, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 26)),
        centerTitle: false,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: darkBlue))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 160, height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(45),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                          image: _fotoPlatillo != null ? DecorationImage(image: FileImage(_fotoPlatillo!), fit: BoxFit.cover) : null,
                        ),
                        child: _fotoPlatillo == null ? const Center(child: Icon(Icons.restaurant, size: 50, color: Color(0xFFD1D5DB))) : null,
                      ),
                      GestureDetector(
                        onTap: _mostrarOpcionesDeFoto, 
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

                _buildLabel('NOMBRE DEL PLATILLO'),
                _buildTextField(_nombreCtrl, Icons.restaurant, hint: 'Ej. Tacos al Pastor x5'),
                
                const SizedBox(height: 20),
                _buildLabel('PRECIO (\$)'),
                _buildTextField(_precioCtrl, Icons.attach_money, hint: 'Ej. 85.00', isNumber: true),

                const SizedBox(height: 20),
                _buildLabel('CATEGORÍA'),
                _buildDropdownCategoria(), // 🔥 El nuevo selector elegante
                
                const SizedBox(height: 20),
                _buildLabel('DESCRIPCIÓN'),
                _buildTextField(_descripcionCtrl, Icons.notes_rounded, hint: 'Ej. Con piña, cebolla...', maxLines: 4),
              ],
            ),
          ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
          child: SizedBox(
            width: double.infinity,
            height: 65,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _crearPlatillo,
              icon: const Icon(Icons.check, color: Colors.white, size: 24),
              label: const Text('CREAR PLATILLO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.0, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBlue,
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

  // 🔥 NUEVO WIDGET: El menú desplegable (Dropdown) con el mismo estilo de los TextFields
  Widget _buildDropdownCategoria() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: DropdownButtonFormField<String>(
        value: _categoriaSeleccionada,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(24),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Icon(Icons.category_rounded, color: const Color(0xFFF26B2A), size: 24),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22), // Mismo alto que los TextFields
        ),
        items: _categoriasDisponibles.map((String categoria) {
          return DropdownMenuItem<String>(
            value: categoria,
            child: Text(categoria),
          );
        }).toList(),
        onChanged: (String? nuevaCategoria) {
          if (nuevaCategoria != null) {
            setState(() {
              _categoriaSeleccionada = nuevaCategoria;
            });
          }
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, {String hint = '', bool isNumber = false, int maxLines = 1}) {
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
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.normal),
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