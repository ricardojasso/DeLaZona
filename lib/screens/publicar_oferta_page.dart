import 'package:flutter/material.dart';

class PublicarOfertaPage extends StatefulWidget {
  const PublicarOfertaPage({super.key});

  @override
  State<PublicarOfertaPage> createState() => _PublicarOfertaPageState();
}

class _PublicarOfertaPageState extends State<PublicarOfertaPage> {
  final _tituloCtrl = TextEditingController();
  final _vigenciaCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  final Color orangeColor = const Color(0xFFF26B2A);
  final Color darkBlue = const Color(0xFF0F172A);
  final Color bgColor = const Color(0xFFF8F9FA);

  void _publicarOferta() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oferta publicada con éxito'), backgroundColor: Colors.green)
    );
    Navigator.pop(context);
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
        title: Text('Publicar Oferta', style: TextStyle(color: darkBlue, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, fontSize: 26)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- TARJETA NARANJA DE OFERTA GIGANTE ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                color: orangeColor,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [BoxShadow(color: orangeColor.withOpacity(0.3), blurRadius: 25, offset: const Offset(0, 12))],
              ),
              child: const Column(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 50),
                  SizedBox(height: 16),
                  Text('OFERTA DEL DÍA', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: 2.0)),
                  SizedBox(height: 8),
                  Text('VISIBLE PARA TODOS TUS CLIENTES\nLOCALES', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // --- CAMPOS DE TEXTO ESCALADOS ---
            _buildLabel('TÍTULO DE LA OFERTA'),
            _buildTextField(_tituloCtrl, Icons.local_offer_outlined, 'Ej: 2x1 en Tacos'),
            
            const SizedBox(height: 20),
            _buildLabel('VIGENCIA'),
            _buildTextField(_vigenciaCtrl, Icons.access_time_outlined, 'Ej: Hoy hasta las 10 PM'),
            
            const SizedBox(height: 20),
            _buildLabel('DESCRIPCIÓN DE LA PROMO'),
            _buildTextField(_descripcionCtrl, Icons.notes_rounded, 'Detalla qué incluye...', maxLines: 4),
          ],
        ),
      ),
      
      // --- BOTÓN AZUL OSCURO GIGANTE ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 10),
          child: SizedBox(
            width: double.infinity,
            height: 65,
            child: ElevatedButton.icon(
              onPressed: _publicarOferta,
              icon: const Icon(Icons.check, color: Colors.white, size: 24),
              label: const Text('PUBLICAR AHORA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2.0, fontSize: 16)),
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

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: TextField(
        controller: controller,
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