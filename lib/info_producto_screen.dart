import 'package:flutter/material.dart';

class InfoProductoScreen extends StatefulWidget {
  final String nombre;
  final String categoria;
  final int stock;
  final String precio;
  final String infoRelevante;

  const InfoProductoScreen({
    super.key,
    required this.nombre,
    required this.categoria,
    required this.stock,
    required this.precio,
    required this.infoRelevante,
  });

  @override
  State<InfoProductoScreen> createState() => _InfoProductoScreenState();
}

class _InfoProductoScreenState extends State<InfoProductoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Información del producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nombre,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              'Categoría: ${widget.categoria}',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              'Stock: ${widget.stock}',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Text(
              'Precio: ${widget.precio}',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            if (widget.infoRelevante.isNotEmpty) ...[
              Text(
                'Info relevante:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const SizedBox(height: 8),
              Text(
                widget.infoRelevante,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
