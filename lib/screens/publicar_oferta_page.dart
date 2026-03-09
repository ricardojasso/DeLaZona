import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicarOfertaPage extends StatefulWidget {
  const PublicarOfertaPage({super.key});

  @override
  State<PublicarOfertaPage> createState() => _PublicarOfertaPageState();
}

class _PublicarOfertaPageState extends State<PublicarOfertaPage> {
  final Color darkBlue = const Color(0xFF0F172A);
  final Color orangeColor = const Color(0xFFF26B2A);
  final Color bgColor = const Color(0xFFF7F8FA);

  final TextEditingController _tituloCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;

//calendario 
  Future<void> _seleccionarFechas() async {
    DateTimeRange? rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(), // No pueden elegir días en el pasado
      lastDate: DateTime.now().add(const Duration(days: 365)), // Hasta 1 año
      helpText: 'Selecciona la duración de la oferta',
      cancelText: 'CANCELAR',
      confirmText: 'GUARDAR',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: orangeColor,
              onPrimary: Colors.white,
              onSurface: darkBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (rango != null) {
      setState(() {
        _fechaInicio = rango.start;
        _fechaFin = rango.end;
      });
    }
  }


  Future<void> _publicarOferta() async {
    if (_tituloCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ponle un título a tu oferta'), backgroundColor: Colors.red));
      return;
    }
    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor selecciona las fechas de vigencia'), backgroundColor: Colors.red));
      return;
    }

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      
      await FirebaseFirestore.instance.collection('restaurantes').doc(uid).update({
        'promocion': _tituloCtrl.text.trim(),
        'promocion_descripcion': _descCtrl.text.trim(),
        'promocion_inicio': Timestamp.fromDate(_fechaInicio!),
        'promocion_fin': Timestamp.fromDate(_fechaFin!),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Oferta publicada con éxito!'), backgroundColor: Colors.green)
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _eliminarOferta() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('restaurantes').doc(uid).update({
      'promocion': '',
      'promocion_inicio': FieldValue.delete(),
      'promocion_fin': FieldValue.delete(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Oferta eliminada'), backgroundColor: Colors.orange));
      Navigator.pop(context);
    }
  }

  String _formatearFecha(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Publicar Oferta',
          style: TextStyle(color: darkBlue, fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            tooltip: 'Eliminar oferta actual',
            onPressed: _eliminarOferta,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TARJETA NARANJA ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: orangeColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: orangeColor.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 16),
                  const Text('OFERTA DEL DÍA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2.0)),
                  const SizedBox(height: 8),
                  Text('VISIBLE PARA TODOS TUS CLIENTES\nLOCALES', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- FORMULARIO ---
            _buildLabel('TÍTULO DE LA OFERTA'),
            _buildTextField(
              controller: _tituloCtrl,
              hint: 'Ej: 2x1 en Tacos',
              icon: Icons.local_offer_outlined,
            ),
            const SizedBox(height: 24),

            _buildLabel('VIGENCIA (FECHAS)'),
            // Selector de fechas en lugar de texto libre
            GestureDetector(
              onTap: _seleccionarFechas,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))]),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded, color: orangeColor, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _fechaInicio != null && _fechaFin != null
                            ? 'Del ${_formatearFecha(_fechaInicio!)} al ${_formatearFecha(_fechaFin!)}'
                            : 'Toca para seleccionar fechas...',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _fechaInicio != null ? darkBlue : Colors.grey.shade400),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('DESCRIPCIÓN DE LA PROMO'),
            _buildTextField(
              controller: _descCtrl,
              hint: 'Detalla qué incluye...',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 40),

            // --- BOTÓN PUBLICAR ---
            ElevatedButton.icon(
              onPressed: _publicarOferta,
              icon: const Icon(Icons.check_rounded, color: Colors.white),
              label: const Text('PUBLICAR AHORA', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBlue,
                minimumSize: const Size(double.infinity, 65),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                shadowColor: darkBlue.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 16, top: 4, bottom: 4), // Ajuste para que el icono quede bien si es multilinea
            child: Icon(icon, color: orangeColor, size: 24),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }
}