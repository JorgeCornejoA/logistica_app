import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddDireccionScreen extends StatefulWidget {
  @override
  _AddDireccionScreenState createState() => _AddDireccionScreenState();
}

class _AddDireccionScreenState extends State<AddDireccionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos del formulario
  final TextEditingController _lugarController = TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _coloniaController = TextEditingController();
  final TextEditingController _cpController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();

  Future<void> agregarDireccion() async {
    if (_formKey.currentState!.validate()) {
      // Muestra un indicador de progreso mientras se realiza la inserción
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      try {
        // Intentar insertar la nueva dirección en la base de datos
        final response = await Supabase.instance.client.from('direcciones').insert({
          'lugar': _lugarController.text,
          'rfc': _rfcController.text,
          'calle': _calleController.text,
          'numero': _numeroController.text,
          'colonia': _coloniaController.text,
          'cp': _cpController.text,
          'ciudad': _ciudadController.text,
          'estado': _estadoController.text,
        }).select();

        // Si hubo un error en la inserción
        if (response == null || response.isEmpty) {
          Navigator.pop(context); // Cerrar el indicador de progreso
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error al agregar la dirección.'),
          ));
        } else {
          // Dirección agregada exitosamente
          Navigator.pop(context); // Cerrar el indicador de progreso
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Dirección agregada con éxito.'),
          ));
          Navigator.pop(context, true); // Regresa a la pantalla anterior con éxito
        }
      } catch (e) {
        // Manejo de cualquier error inesperado
        Navigator.pop(context); // Cerrar el indicador de progreso
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Dirección'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _lugarController,
                decoration: InputDecoration(labelText: 'Lugar'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _rfcController,
                decoration: InputDecoration(labelText: 'RFC'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _calleController,
                decoration: InputDecoration(labelText: 'Calle'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _numeroController,
                decoration: InputDecoration(labelText: 'Número'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _coloniaController,
                decoration: InputDecoration(labelText: 'Colonia'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cpController,
                decoration: InputDecoration(labelText: 'Código Postal'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ciudadController,
                decoration: InputDecoration(labelText: 'Ciudad'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _estadoController,
                decoration: InputDecoration(labelText: 'Estado'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: agregarDireccion,
                child: Text('Agregar Dirección'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
