import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logistica_app/login_screen.dart';
  import 'package:share_plus/share_plus.dart'; // Para compartir como PDF (opcional)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mcwwjqsirkniposolwez.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1jd3dqcXNpcmtuaXBvc29sd2V6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgwMTU4ODAsImV4cCI6MjA0MzU5MTg4MH0.0HNHL3WGBSSP9zzj0KL-TxNAky1qn0SJukEDSZksJdw',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Direcciones cargas y descargas - Fruver',
      theme: ThemeData(
        primarySwatch: Colors.green, // Cambia el color primario a tonos verdes
        scaffoldBackgroundColor: Colors.green[50], // Fondo suave verde
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[700], // Color de la AppBar
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            // Cambia el color del texto del título a blanco
            color: Colors.white,
            fontSize: 20, // Ajustar el tamaño de la fuente
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.green, // Color del botón flotante
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600], // Color de botones elevados
          ),
        ),
      ),
      home: AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    
    // Verifica si hay una sesión activa
    if (session != null) {
      // Si hay sesión, redirige a la HomePage
      return HomePage(); // Cambia esto a tu HomePage
    } else {
      // Si no hay sesión, redirige al LoginPage
      return LoginPage();
    }
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _direcciones = [];
  List<dynamic> _direccionesFiltradas = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    obtenerDirecciones();
    _searchController.addListener(_filtrarDirecciones);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> obtenerDirecciones() async {
  final response = await Supabase.instance.client.from('direcciones').select();
  setState(() {
    _direcciones = response;
    _direcciones.sort((a, b) => a['id'].compareTo(b['id']));
    _direccionesFiltradas = _direcciones;
  });
}


  Future<void> refrescarDirecciones() async {
    await obtenerDirecciones();
  }

  void _filtrarDirecciones() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _direccionesFiltradas = _direcciones.where((direccion) {
        final lugar = direccion['lugar'].toString().toLowerCase();
        final ciudad = direccion['ciudad'].toString().toLowerCase();
        return lugar.contains(query) || ciudad.contains(query);
      }).toList();
    });
  }
  final _supabase = Supabase.instance.client;

  Future<void> signOut(BuildContext context) async {
    try {
      await _supabase.auth.signOut();
      // Redirige al usuario de vuelta a la pantalla de inicio de sesión
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión. Intente nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmLogout() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Cerrar Sesión'),
        content: Text('¿Está seguro de que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _supabase.auth.signOut();
              Navigator.of(context).pop(); // Cerrar el diálogo
              // Redirigir a la página de login si es necesario
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Text('Cerrar Sesión'),
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fruver - Direcciones carga y descarga'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            // onPressed: () => signOut(context),
            onPressed: _confirmLogout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por lugar o ciudad',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh:
                  refrescarDirecciones, // Función para refrescar al deslizar
              child: _direccionesFiltradas.isEmpty
                  ? Center(
                      child: _searchController.text.isEmpty
                          ? CircularProgressIndicator() // Mostramos el círculo de carga solo si no se ha hecho una búsqueda
                          : Text(
                              'No hay resultados que coincidan con la búsqueda'),
                    )
                  : ListView.builder(
                      itemCount: _direccionesFiltradas.length,
                      itemBuilder: (context, index) {
                        final direccion = _direccionesFiltradas[index];
                        return Card(
                          child: ListTile(
                            title: Text(direccion['lugar']),
                            subtitle: Text(
                                '${direccion['calle']} ${direccion['numero']}, ${direccion['colonia']}'),
                            onTap: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetalleDireccionPage(direccion: direccion),
    ),
  );

  if (result == true) {
    await obtenerDirecciones(); // Refresca la lista si hubo eliminación o edición
  }
},

                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddDireccionScreen(),
            ),
          );

          if (result == true) {
            obtenerDirecciones();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// Pantalla de detalles de la dirección seleccionada
class DetalleDireccionPage extends StatelessWidget {
  final Map<String, dynamic> direccion;

  DetalleDireccionPage({required this.direccion});

  Future<void> eliminarDireccion() async {
    try {
      await Supabase.instance.client
          .from('direcciones')
          .delete()
          .eq('id', direccion['id']);

      print('Dirección eliminada correctamente.');
    } catch (e) {
      print('Error al eliminar la dirección: $e');
    }
  }

  void compartirComoPDF() {
    final direccionFormateada = '''
Detalles de la dirección:

Lugar: ${direccion['lugar']}
RFC: ${direccion['rfc']}
Calle: ${direccion['calle']} ${direccion['numero']}
Colonia: ${direccion['colonia']}
CP: ${direccion['cp']}
Ciudad: ${direccion['ciudad']}
Estado: ${direccion['estado']}
''';

    Share.share(direccionFormateada);
  }

void mostrarPopupEliminar(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar esta dirección?'),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Eliminar'),
            onPressed: () async {
              await eliminarDireccion();
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Notifica a HomePage
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final direccionCompleta = '''
Lugar: ${direccion['lugar']}
RFC: ${direccion['rfc']}
Calle: ${direccion['calle']} ${direccion['numero']}
Colonia: ${direccion['colonia']}
CP: ${direccion['cp']}
Ciudad: ${direccion['ciudad']}
Estado: ${direccion['estado']}
''';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la Dirección'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              direccionCompleta,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditarDireccionPage(direccion: direccion),
                      ),
                    );

                    if (result == true) {
                      Navigator.of(context).pop(true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // Color del texto en blanco
                  ),
                  child: Text('Editar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    mostrarPopupEliminar(context);
                  },
                  child: Text('Eliminar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white, // Color del texto en blanco
                  ),
                ),
                ElevatedButton(
                  onPressed: compartirComoPDF,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // Color del texto en blanco
                  ),
                  child: Text('Compartir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla de edición de la dirección seleccionada
class EditarDireccionPage extends StatefulWidget {
  final Map<String, dynamic> direccion;

  EditarDireccionPage({required this.direccion});

  @override
  _EditarDireccionPageState createState() => _EditarDireccionPageState();
}

class _EditarDireccionPageState extends State<EditarDireccionPage> {
  late TextEditingController _lugarController;
  late TextEditingController _rfcController;
  late TextEditingController _calleController;
  late TextEditingController _numeroController;
  late TextEditingController _coloniaController;
  late TextEditingController _cpController;
  late TextEditingController _ciudadController;
  late TextEditingController _estadoController;

  @override
  void initState() {
    super.initState();
    _lugarController = TextEditingController(text: widget.direccion['lugar']);
    _rfcController = TextEditingController(text: widget.direccion['rfc']);
    _calleController = TextEditingController(text: widget.direccion['calle']);
    _numeroController = TextEditingController(text: widget.direccion['numero']);
    _coloniaController =
        TextEditingController(text: widget.direccion['colonia']);
    _cpController = TextEditingController(text: widget.direccion['cp']);
    _ciudadController = TextEditingController(text: widget.direccion['ciudad']);
    _estadoController = TextEditingController(text: widget.direccion['estado']);
  }

  @override
  void dispose() {
    _lugarController.dispose();
    _rfcController.dispose();
    _calleController.dispose();
    _numeroController.dispose();
    _coloniaController.dispose();
    _cpController.dispose();
    _ciudadController.dispose();
    _estadoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    try {
      await Supabase.instance.client.from('direcciones').update({
        'lugar': _lugarController.text,
        'rfc': _rfcController.text,
        'calle': _calleController.text,
        'numero': _numeroController.text,
        'colonia': _coloniaController.text,
        'cp': _cpController.text,
        'ciudad': _ciudadController.text,
        'estado': _estadoController.text,
      }).eq('id', widget.direccion['id']);

      Navigator.of(context).pop(true); // Regresar y actualizar la lista
    } catch (e) {
      print('Error al actualizar la dirección: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Dirección'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
              ),
              TextField(
                controller: _coloniaController,
                decoration: InputDecoration(labelText: 'Colonia'),
              ),
              TextField(
                controller: _cpController,
                decoration: InputDecoration(labelText: 'CP'),
              ),
              TextField(
                controller: _ciudadController,
                decoration: InputDecoration(labelText: 'Ciudad'),
              ),
              TextField(
                controller: _estadoController,
                decoration: InputDecoration(labelText: 'Estado'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarCambios,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Color del texto en blanco
                ),
                child: Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla de añadir una nueva dirección
class AddDireccionScreen extends StatefulWidget {
  @override
  _AddDireccionScreenState createState() => _AddDireccionScreenState();
}

class _AddDireccionScreenState extends State<AddDireccionScreen> {
  final TextEditingController _lugarController = TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _coloniaController = TextEditingController();
  final TextEditingController _cpController = TextEditingController();
  final TextEditingController _ciudadController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();

  @override
  void dispose() {
    _lugarController.dispose();
    _calleController.dispose();
    _ciudadController.dispose();
    // Disponer otros controladores
    super.dispose();
  }

  Future<void> _agregarDireccion() async {
    // Validación de campos obligatorios
    if (_lugarController.text.isEmpty || _calleController.text.isEmpty || _ciudadController.text.isEmpty) {
      _mostrarAlerta('Por favor, complete los campos obligatorios: Lugar, Calle y Ciudad');
      return; // Salir si algún campo obligatorio está vacío
    }

    try {
      await Supabase.instance.client.from('direcciones').insert({
        'lugar': _lugarController.text,
        'rfc': _rfcController.text,
        'calle': _calleController.text,
        'numero': _numeroController.text,
        'colonia': _coloniaController.text,
        'cp': _cpController.text,
        'ciudad': _ciudadController.text,
        'estado': _estadoController.text,
      });

      Navigator.of(context).pop(true); // Regresar y actualizar la lista
    } catch (e) {
      print('Error al agregar la dirección: $e');
    }
  }

  void _mostrarAlerta(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Campos obligatorios'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Dirección'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
              ),
              TextField(
                controller: _coloniaController,
                decoration: InputDecoration(labelText: 'Colonia'),
              ),
              TextField(
                controller: _cpController,
                decoration: InputDecoration(labelText: 'CP'),
              ),
              TextField(
                controller: _ciudadController,
                decoration: InputDecoration(labelText: 'Ciudad'),
              ),
              TextField(
                controller: _estadoController,
                decoration: InputDecoration(labelText: 'Estado'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _agregarDireccion,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Color del texto en blanco
                ),
                child: Text('Añadir Dirección'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
