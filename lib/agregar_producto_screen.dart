import 'package:flutter/material.dart';
import 'producto_inventario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({Key? key}) : super(key: key);

  @override
  State<AgregarProductoScreen> createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();

  String? _apartadoSeleccionado;

  final List<String> apartados = [
    'Overhall', 'Discos de fricción', 'Bandas', 'Filtros', 'Pistones', 'Retenedores', 'Bushing', 'Empaques', 'Discos sueltos', 'Metales', 'Varios',
  ];

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;
    if (_apartadoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un apartado.')));
      return;
    }
    String precio = _precioController.text.trim();
    if (precio.isNotEmpty && !precio.startsWith('₡')) {
      precio = '₡' + precio;
    }
    final producto = ProductoInventario(
      nombre: _nombreController.text.trim(),
      categoria: _categoriaController.text.trim(),
      stock: int.tryParse(_cantidadController.text.trim()) ?? 0,
      precio: precio,
      infoRelevante: _infoController.text.trim(),
    );
    // Guardar en Firestore
    final coleccion = _apartadoSeleccionado!.toLowerCase().replaceAll(' ', '_');
    await FirebaseFirestore.instance.collection(coleccion).add({
      'nombre': producto.nombre,
      'categoria': producto.categoria,
      'stock': producto.stock,
      'precio': producto.precio,
      'infoRelevante': producto.infoRelevante,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto agregado correctamente.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar producto'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre del producto', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese la categoría' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese la cantidad';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0) return 'Cantidad inválida';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(labelText: 'Precio', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _infoController,
                decoration: const InputDecoration(labelText: 'Información relevante', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _apartadoSeleccionado,
                decoration: const InputDecoration(labelText: 'Elija el apartado', border: OutlineInputBorder()),
                items: apartados.map((apart) => DropdownMenuItem(
                  value: apart,
                  child: Text(apart),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _apartadoSeleccionado = value;
                  });
                },
                validator: (v) => v == null ? 'Seleccione un apartado' : null,
                isExpanded: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarProducto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
