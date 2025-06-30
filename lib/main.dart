import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import './inventario_screen.dart';
import './info_producto_screen.dart'; //  <-- 1. IMPORTA TU NUEVA PANTALLA AQUÍ
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // <-- Asegúrate de tener esto


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InventoryApp());
}


class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _opacity = 0.0;
  double _scale = 0.8;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Es una buena práctica configurar el modo de liberación para efectos de sonido cortos
    _audioPlayer.setReleaseMode(ReleaseMode.stop); 
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });
  }

  @override
  void dispose() {
    // Libera los recursos del reproductor de audio cuando el widget se destruye
    _audioPlayer.dispose();
    super.dispose();
    }

  Future<void> _playClickSound() async {
    await _audioPlayer.play(AssetSource('sounds/click.mp3'));
  }

  Widget buildButton(IconData icon, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: StatefulBuilder(
        builder: (context, setInnerState) {
          double scale = 1.0;

          return AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 100),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 70),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Colors.white,
                shadowColor: Colors.black26,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              icon: Icon(icon, size: 28, color: Colors.deepPurple),
              label:
                  Text(label, style: const TextStyle(color: Colors.deepPurple)),
              onPressed: () async {
                setInnerState(() => scale = 0.93);
                await Future.delayed(const Duration(milliseconds: 80));
                setInnerState(() => scale = 1.0);

                await _playClickSound();
                onPressed(); // ⬅️ ejecuta la acción del botón (si tiene)
              },
            ),
          );
        },
      ),
    );
  }

  void _probarFirestore() async {
    // Escribir un producto de prueba
    await FirebaseFirestore.instance.collection('productos').doc('prueba').set({
      'nombre': 'Producto de prueba',
      'categoria': 'Test',
      'stock': 10,
      'precio': 123.45,
    });

    // Leer el producto de prueba
    var doc = await FirebaseFirestore.instance.collection('productos').doc('prueba').get();
    print('Producto leído:');
    print(doc.data());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Firestore prueba OK: ' + (doc.data()?['nombre'] ?? 'Sin datos'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFFF),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Inicio'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: const Duration(milliseconds: 700),
              child: AnimatedScale(
                scale: _scale,
                duration: const Duration(milliseconds: 700),
                child: const CircleAvatar(
                  backgroundImage: AssetImage('assets/logo.png'),
                  radius: 60,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            buildButton(Icons.inventory, 'Inventario', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InventarioScreen()),
              );
            }),
            buildButton(Icons.warning_amber_rounded, 'Alertas de Stock Bajo', () {}),
            buildButton(Icons.add_circle_outline, 'Agregar Producto', () {}),
            buildButton(Icons.search, 'Buscar Producto', () {}),
            buildButton(Icons.settings, 'Configuración', _probarFirestore),
            const Spacer(),
            const Text(
              'Versión 1.0.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
