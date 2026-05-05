import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/restaurante/campo_formulario.dart';
import '../../widgets/restaurante/etiqueta_formulario.dart';
import '../../widgets/restaurante/tarjeta_informativa_oferta.dart';
import '../../widgets/restaurante/selector_fecha_oferta.dart';
import '../../services/Restaurante/restaurante_service.dart';

class PublicarOfertaPage extends StatefulWidget {
  const PublicarOfertaPage({super.key});

  @override
  State<PublicarOfertaPage> createState() => _PublicarOfertaPageState();
}

class _PublicarOfertaPageState extends State<PublicarOfertaPage> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  final RestauranteService _restauranteService = RestauranteService(); // <-- NUESTRO SERVICIO

  final Color _darkBlue = const Color(0xFF0F172A);
  final Color _bgColor = const Color(0xFFF7F8FA);

  final TextEditingController _tituloCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  // 1. LÓGICA DE CALENDARIO Y BASE DE DATOS

  Future<void> _seleccionarFechas() async {
    DateTimeRange? rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(), 
      lastDate: DateTime.now().add(const Duration(days: 365)), 
      helpText: 'Selecciona la duración de la oferta',
      cancelText: 'CANCELAR', confirmText: 'GUARDAR',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: const Color(0xFFF26B2A), onPrimary: Colors.white, onSurface: _darkBlue),
          ),
          child: child!,
        );
      },
    );

    if (rango != null) setState(() { _fechaInicio = rango.start; _fechaFin = rango.end; });
  }

  Future<void> _publicarOferta() async {
    if (_tituloCtrl.text.isEmpty || _fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Revisa el título y las fechas'), backgroundColor: Colors.red));
      return;
    }

    try {
      await _restauranteService.publicarOferta(
        uid: _uid,
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        fechaInicio: _fechaInicio!,
        fechaFin: _fechaFin!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Oferta publicada!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _eliminarOferta() async {
    try {
      await _restauranteService.eliminarOferta(_uid);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Oferta eliminada'), backgroundColor: Colors.orange));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  // 2. INTERFAZ GRÁFICA 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor, elevation: 0, centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: _darkBlue), onPressed: () => Navigator.pop(context)),
        title: Text('Publicar Oferta', style: TextStyle(color: _darkBlue, fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic)),
        actions: [IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.red), tooltip: 'Eliminar oferta actual', onPressed: _eliminarOferta)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TarjetaInformativaOferta(),
            const SizedBox(height: 40),

            const EtiquetaFormulario(texto: 'TÍTULO DE LA OFERTA'),
            CampoFormulario(controlador: _tituloCtrl, hint: 'Ej: 2x1 en Tacos', icono: Icons.local_offer_outlined),
            const SizedBox(height: 24),

            const EtiquetaFormulario(texto: 'VIGENCIA (FECHAS)'),
            SelectorFechaOferta(fechaInicio: _fechaInicio, fechaFin: _fechaFin, onTap: _seleccionarFechas),
            const SizedBox(height: 24),

            const EtiquetaFormulario(texto: 'DESCRIPCIÓN DE LA PROMO'),
            CampoFormulario(controlador: _descCtrl, hint: 'Detalla qué incluye...', icono: Icons.notes_rounded, maxLines: 3),
            const SizedBox(height: 40),

            ElevatedButton.icon(
              onPressed: _publicarOferta,
              icon: const Icon(Icons.check_rounded, color: Colors.white),
              label: const Text('PUBLICAR AHORA', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkBlue, minimumSize: const Size(double.infinity, 65),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 10, shadowColor: _darkBlue.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}