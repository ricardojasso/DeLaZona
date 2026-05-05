import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// --- IMPORTAMOS LOS SERVICIOS Y WIDGETS ---
import '../../services/auth_service.dart';
import '../../services/Restaurante/platillos_service.dart';
import '../../widgets/restaurante/campo_formulario.dart';
import '../../widgets/restaurante/selector_categoria.dart';
import '../../widgets/restaurante/etiqueta_formulario.dart';
import '../../widgets/restaurante/selector_imagen_platillo.dart';

class AgregarPlatilloPage extends StatefulWidget {
  const AgregarPlatilloPage({super.key});

  @override
  State<AgregarPlatilloPage> createState() => _AgregarPlatilloPageState();
}

class _AgregarPlatilloPageState extends State<AgregarPlatilloPage> {
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  
  final List<String> _categoriasDisponibles = [
    'Entradas y Aperitivos', 'Platos Fuertes', 'Desayunos', 'Bebidas',
    'Postres', 'Snacks y Botanas', 'Guarniciones o Extras', 'Especialidades', 'Otros'
  ];
  String _categoriaSeleccionada = 'Platos Fuertes'; 
  
  File? _fotoPlatillo;
  bool _isLoading = false;

  final Color _darkBlue = const Color(0xFF0F172A);

  // ==========================================
  // 1. LÓGICA DE FOTOS Y GUARDADO (CON SERVICIO)
  // ==========================================

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
                Text('Foto del Platillo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _darkBlue)),
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
    if (pickedFile != null) setState(() => _fotoPlatillo = File(pickedFile.path));
  }

  Future<void> _crearPlatillo() async {
    if (_nombreCtrl.text.isEmpty || _precioCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Llena el nombre y el precio'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔥 OBTENEMOS EL UID DESDE NUESTRO SERVICIO DE AUTENTICACIÓN 🔥
      String uidUsuario = AuthService().usuarioActual!.uid;
      
      // Llamada al servicio de platillos
      await PlatillosService().crearPlatillo(
        uidRestaurante: uidUsuario,
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        precio: double.parse(_precioCtrl.text.trim()),
        categoria: _categoriaSeleccionada,
        fotoPlatillo: _fotoPlatillo,
      );

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

  // ==========================================
  // 2. INTERFAZ GRÁFICA (UI) 
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA), elevation: 0, toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 12, bottom: 12),
          child: Container(decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 2)), child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.blueGrey, size: 22), onPressed: () => Navigator.pop(context))),
        ),
        title: Text('Añadir Platillo', style: TextStyle(color: _darkBlue, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 26)), centerTitle: false,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: _darkBlue))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectorImagenPlatillo(imagenFila: _fotoPlatillo, onTapCamara: _mostrarOpcionesDeFoto),
                const SizedBox(height: 40),

                const EtiquetaFormulario(texto: 'NOMBRE DEL PLATILLO'),
                CampoFormulario(controlador: _nombreCtrl, hint: 'Ej. Tacos al Pastor x5', icono: Icons.restaurant),
                const SizedBox(height: 20),

                const EtiquetaFormulario(texto: 'PRECIO (\$)'),
                CampoFormulario(controlador: _precioCtrl, hint: 'Ej. 85.00', icono: Icons.attach_money, isNumber: true),
                const SizedBox(height: 20),

                const EtiquetaFormulario(texto: 'CATEGORÍA'),
                SelectorCategoria(
                  valorActual: _categoriaSeleccionada, opciones: _categoriasDisponibles, 
                  onChanged: (val) { if (val != null) setState(() => _categoriaSeleccionada = val); }
                ),
                const SizedBox(height: 20),

                const EtiquetaFormulario(texto: 'DESCRIPCIÓN'),
                CampoFormulario(controlador: _descripcionCtrl, hint: 'Ej. Con piña, cebolla...', icono: Icons.notes_rounded, maxLines: 4),
              ],
            ),
          ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
          child: SizedBox(
            width: double.infinity, height: 65,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _crearPlatillo,
              icon: const Icon(Icons.check, color: Colors.white, size: 24),
              label: const Text('CREAR PLATILLO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.0, fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: _darkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0),
            ),
          ),
        ),
      ),
    );
  }
}