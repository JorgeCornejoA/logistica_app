import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_direccion_screen.dart'; // Asegúrate de importar la pantalla de edición

class DetalleDireccionPage extends StatelessWidget {
  final Map<String, dynamic> direccion;

  const DetalleDireccionPage({super.key, required this.direccion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la Dirección'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lugar: ${direccion['lugar']}', style: const TextStyle(fontSize: 18)),
            Text('RFC: ${direccion['rfc']}', style: const TextStyle(fontSize: 18)),
            Text('Calle: ${direccion['calle']}', style: const TextStyle(fontSize: 18)),
            Text('Número: ${direccion['numero']}', style: const TextStyle(fontSize: 18)),
            Text('Colonia: ${direccion['colonia']}', style: const TextStyle(fontSize: 18)),
            Text('CP: ${direccion['cp']}', style: const TextStyle(fontSize: 18)),
            Text('Ciudad: ${direccion['ciudad']}', style: const TextStyle(fontSize: 18)),
            Text('Estado: ${direccion['estado']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            // Botón de editar
            ElevatedButton(
              onPressed: () async {
                print('ID de dirección a editar: ${direccion['id']}');  // Imprimir ID para depuración

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarDireccionPage(direccion: direccion),
                  ),
                );

                if (result == true) {
                  print('Dirección editada exitosamente');
                  Navigator.pop(context, true); // Refresca la pantalla anterior
                } else {
                  print('La edición de la dirección no fue exitosa.');
                }
              },
              child: const Text('Editar'),
            ),

            const SizedBox(height: 10),

            // Botón de eliminar
            ElevatedButton(
              onPressed: () async {
                print('ID de dirección a eliminar: ${direccion['id']}');  // Imprimir ID para depuración
                try {
                  final response = await Supabase.instance.client
                      .from('direcciones')
                      .delete()
                      .eq('id', direccion['id'])
                      .select();  // Select para recibir los datos eliminados

                  if (response != null && response.isNotEmpty) {
                    print('Dirección eliminada exitosamente: $response');
                    Navigator.pop(context, true); // Regresa a la pantalla anterior tras eliminar
                  } else {
                    print('Error al eliminar la dirección: no se recibió respuesta.');
                  }
                } catch (error) {
                  print('Error al eliminar dirección: $error');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error al eliminar la dirección: $error'),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),

            const SizedBox(height: 10),

            // Botón para compartir como PDF (opcional)
            ElevatedButton(
              onPressed: () {
                // Implementar función para compartir como PDF
                print('Compartir como PDF');
              },
              child: const Text('Compartir'),
            ),
          ],
        ),
      ),
    );
  }
}
