import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditarDireccionPage extends StatelessWidget {
  final Map<String, dynamic> direccion;
  final TextEditingController _lugarController = TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _coloniaController = TextEditingController();
  final TextEditingController _cpController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();

  EditarDireccionPage({required this.direccion}) {
    _lugarController.text = direccion['lugar'];
    _rfcController.text = direccion['rfc'];
    _calleController.text = direccion['calle'];
    _numeroController.text = direccion['numero'].toString();
    _coloniaController.text = direccion['colonia'];
    _cpController.text = direccion['cp'].toString();
    _ciudadController.text = direccion['ciudad'];
    _estadoController.text = direccion['estado'];
  }

  Future<void> editarDireccion(BuildContext context) async {
    final updatedData = {
      'lugar': _lugarController.text,
      'rfc': _rfcController.text,
      'calle': _calleController.text,
      'numero': int.tryParse(_numeroController.text),
      'colonia': _coloniaController.text,
      'cp': int.tryParse(_cpController.text),
      'ciudad': _ciudadController.text,
      'estado': _estadoController.text,
    };

    try {
      await Supabase.instance.client
          .from('direcciones')
          .update(updatedData)
          .eq('id', direccion['id']);

      Navigator.pop(context, true); // Regresar a la pantalla anterior
    } catch (e) {
      print('Error al editar la dirección: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Dirección'),
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _lugarController,
              decoration: InputDecoration(labelText: 'Lugar'),
            ),
            TextField(
              controller: _rfcController,
              decoration: InputDecoration(labelText: 'RFC'),
            ),
            TextField(
              controller: _calleController,
              decoration: InputDecoration(labelText: 'Calle'),
            ),
            TextField(
              controller: _numeroController,
              decoration: InputDecoration(labelText: 'Número'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _coloniaController,
              decoration: InputDecoration(labelText: 'Colonia'),
            ),
            TextField(
              controller: _cpController,
              decoration: InputDecoration(labelText: 'CP'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ciudadController,
              decoration: InputDecoration(labelText: 'Ciudad'),
            ),
            TextField(
              controller: _estadoController,
              decoration: InputDecoration(labelText: 'Estado'),
            ),
            SizedBox(height: 20), // Espacio adicional
            Center( // Centrar el botón
              child: ElevatedButton(
                onPressed: () => editarDireccion(context),
                child: Text('Guardaaaaaaaaar Cambios'),
              ),
            ),
            SizedBox(height: 40), // Espacio inferior
          ],
        ),
      ),
      resizeToAvoidBottomInset: true, // Ajustar al teclado
    );
  }
}
