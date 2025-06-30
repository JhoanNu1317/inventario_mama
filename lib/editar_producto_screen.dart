import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'producto_inventario.dart';
import 'productos_data.dart';

class EditarProductoScreen extends StatefulWidget {
  final ProductoInventario producto;
  final String coleccion;

  const EditarProductoScreen({
    super.key,
    required this.producto,
    required this.coleccion,
  });

  @override
  State<EditarProductoScreen> createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  late TextEditingController _precioController;
  late TextEditingController _categoriaController;
  late TextEditingController _infoController;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _precioController = TextEditingController(text: widget.producto.precio);
    _categoriaController = TextEditingController(text: widget.producto.categoria);
    _infoController = TextEditingController(text: widget.producto.infoRelevante);
  }

  @override
  void dispose() {
    _precioController.dispose();
    _categoriaController.dispose();
    _infoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    setState(() { _guardando = true; _error = null; });
    if (_precioController.text.trim().isEmpty) {
      setState(() { _error = 'El precio no puede estar vacío.'; _guardando = false; });
      return;
    }
    if (_categoriaController.text.trim().isEmpty) {
      setState(() { _error = 'La categoría del producto no puede estar vacía.'; _guardando = false; });
      return;
    }
    try {
      final query = await FirebaseFirestore.instance
          .collection(widget.coleccion)
          .where('nombre', isEqualTo: widget.producto.nombre)
          .where('categoria', isEqualTo: widget.producto.categoria)
          .get();
      for (var doc in query.docs) {
        await doc.reference.update({
          'precio': _precioController.text.trim(),
          'categoria': _categoriaController.text.trim(),
          'infoRelevante': _infoController.text.trim(),
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados correctamente'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() { _error = 'Error al guardar: $e'; });
    } finally {
      setState(() { _guardando = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar producto'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${widget.producto.nombre}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoriaController,
              decoration: const InputDecoration(labelText: 'Categoría (código, ej: A750, Nada, Transna, etc.)'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _infoController,
              decoration: const InputDecoration(labelText: 'Información'),
              maxLines: 2,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardarCambios,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: _guardando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
