import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/Restaurante/platillos_service.dart';
import '../../widgets/restaurante/campo_formulario.dart';
import '../../widgets/restaurante/selector_categoria.dart';
import '../../widgets/restaurante/etiqueta_formulario.dart';
import '../../widgets/restaurante/selector_imagen_platillo.dart';

class EditarPlatilloPage extends StatefulWidget {
  final String idPlatillo;
  final Map<String, dynamic> datosActuales;

  const EditarPlatilloPage({
    super.key, required this.idPlatillo, required this.datosActuales
  });

  @override
  State<EditarPlatilloPage> createState() => _EditarPlatilloPageState();
}

class _EditarPlatilloPageState extends State<EditarPlatilloPage> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _descripcionCtrl;
  
  final List<String> _categoriasDisponibles = [
    'Entradas y Aperitivos', 'Platos Fuertes', 'Desayunos', 'Bebidas',
    'Postres', 'Snacks y Botanas', 'Guarniciones o Extras', 'Especialidades', 'Otros'
  ];
  late String _categoriaSeleccionada; 
  
  File? _nuevaFoto;
  String _fotoUrlExistente = '';
  bool _isLoading = false;

  final Color _darkBlue = const Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.datosActuales['nombre']);
    _precioCtrl = TextEditingController(text: widget.datosActuales['precio'].toString());
    _descripcionCtrl = TextEditingController(text: widget.datosActuales['descripcion']);
    
    String catGuardada = widget.datosActuales['categoria'] ?? 'Otros';
    _categoriaSeleccionada = _categoriasDisponibles.contains(catGuardada) ? catGuardada : 'Otros';
    _fotoUrlExistente = widget.datosActuales['foto_url'] ?? '';
  }
  // 1. LÓGICA DE FOTOS Y GUARDADO
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
    if (pickedFile != null) setState(() => _nuevaFoto = File(pickedFile.path));
  }

  Future<void> _guardarCambios() async {
    if (_nombreCtrl.text.isEmpty || _precioCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre y precio obligatorios'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String uidUsuario = widget.datosActuales['id_restaurante'];

      // SERVICIO 
      await PlatillosService().actualizarPlatillo(
        idPlatillo: widget.idPlatillo,
        uidRestaurante: uidUsuario,
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        precio: double.parse(_precioCtrl.text.trim()),
        categoria: _categoriaSeleccionada,
        fotoUrlExistente: _fotoUrlExistente,
        nuevaFoto: _nuevaFoto,
      );

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

  // 2. INTERFAZ

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
        title: Text('Editar Platillo', style: TextStyle(color: _darkBlue, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 26)), centerTitle: false,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: _darkBlue))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectorImagenPlatillo(imagenFila: _nuevaFoto, imageUrl: _fotoUrlExistente, onTapCamara: _mostrarOpcionesDeFoto),
                const SizedBox(height: 40),

                const EtiquetaFormulario(texto: 'NOMBRE DEL PLATILLO'),
                CampoFormulario(controlador: _nombreCtrl, hint: '', icono: Icons.restaurant),
                const SizedBox(height: 20),

                const EtiquetaFormulario(texto: 'PRECIO (\$)'),
                CampoFormulario(controlador: _precioCtrl, hint: '', icono: Icons.attach_money, isNumber: true),
                const SizedBox(height: 20),

                const EtiquetaFormulario(texto: 'CATEGORÍA'),
                SelectorCategoria(
                  valorActual: _categoriaSeleccionada, opciones: _categoriasDisponibles,
                  onChanged: (val) { if (val != null) setState(() => _categoriaSeleccionada = val); }
                ),
                const SizedBox(height: 20),

                const EtiquetaFormulario(texto: 'DESCRIPCIÓN'),
                CampoFormulario(controlador: _descripcionCtrl, hint: '', icono: Icons.notes_rounded, maxLines: 4),
              ],
            ),
          ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
          child: SizedBox(
            width: double.infinity, height: 65,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _guardarCambios,
              icon: const Icon(Icons.check, color: Colors.white, size: 24),
              label: const Text('GUARDAR CAMBIOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.0, fontSize: 16)),
              style: ElevatedButton.styleFrom(backgroundColor: _darkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0),
            ),
          ),
        ),
      ),
    );
  }
}