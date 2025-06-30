import 'package:flutter/material.dart';
import './info_producto_screen.dart';
import './productos_data.dart';
import 'producto_inventario.dart';
import 'restock_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  String _selectedCategory = categoriasInventario.first;
  bool _cargandoFirestore = true;

  @override
  void initState() {
    super.initState();
    _poblarColeccionOverhall();
  }

  Future<void> _poblarColeccionOverhall() async {
    for (var producto in productosOverhall) {
      final query = await FirebaseFirestore.instance
          .collection('overhall')
          .where('nombre', isEqualTo: producto.nombre)
          .get();
      if (query.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('overhall').add({
          'nombre': producto.nombre,
          'categoria': producto.categoria,
          'stock': producto.stock,
          'precio': producto.precio,
          'infoRelevante': producto.infoRelevante,
        });
      }
    }
  }

  Stream<List<ProductoInventario>> streamProductosOverhall() {
    return FirebaseFirestore.instance
        .collection('overhall')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return ProductoInventario(
                nombre: data['nombre'] ?? '',
                categoria: data['categoria'] ?? '',
                stock: data['stock'] ?? 0,
                precio: data['precio'] ?? '',
                infoRelevante: data['infoRelevante'] ?? '',
              );
            }).toList());
  }

  Future<void> actualizarStockFirestore(String nombre, String categoria, int nuevoStock, {String coleccion = 'overhall'}) async {
    final query = await FirebaseFirestore.instance
        .collection(coleccion)
        .where('nombre', isEqualTo: nombre)
        .where('categoria', isEqualTo: categoria)
        .get();
    for (var doc in query.docs) {
      await doc.reference.update({'stock': nuevoStock});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Inventario Overhall'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: StreamBuilder<List<ProductoInventario>>(
          stream: streamProductosOverhall(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            }
            final productos = snapshot.data ?? [];
            if (productos.isEmpty) {
              return const Center(child: Text('No hay productos en Overhall.'));
            }
            return _buildProductosList(productos);
          },
        ),
      ),
    );
  }

  Widget _buildProductosList(List<ProductoInventario> productos) {
    return ListView.builder(
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              builder: (context) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline, color: Colors.deepPurple),
                        title: const Text('Ver info', style: TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InfoProductoScreen(
                                nombre: producto.nombre,
                                categoria: producto.categoria,
                                stock: producto.stock,
                                precio: producto.precio,
                                infoRelevante: producto.infoRelevante,
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                        title: const Text('Se vendió', style: TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () async {
                          if (producto.stock > 0) {
                            final nuevoStock = producto.stock - 1;
                            await actualizarStockFirestore(producto.nombre, producto.categoria, nuevoStock, coleccion: 'overhall');
                          }
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.orange),
                        title: const Text('Editar', style: TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () {
                          Navigator.pop(context);
                          // Acción futura
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(producto.nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Categoría: \\${producto.categoria}', style: const TextStyle(fontSize: 15, color: Colors.black54)),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final restock = await showRestockDialog(context);
                          if (restock != null && restock > 0) {
                            final nuevoStock = producto.stock + restock;
                            await actualizarStockFirestore(producto.nombre, producto.categoria, nuevoStock, coleccion: 'overhall');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Se agregaron \\${restock} unidades al stock.')),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: producto.stock > 0 ? Colors.green[100] : Colors.red[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Stock: \\${producto.stock}',
                            style: TextStyle(
                              fontSize: 15,
                              color: producto.stock > 0 ? Colors.green[800] : Colors.red[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (producto.precio != null && producto.precio.trim().isNotEmpty)
                      ? 'Precio: \\${producto.precio}'
                      : 'Precio: Sin precio',
                    style: const TextStyle(fontSize: 15, color: Colors.deepPurple),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
