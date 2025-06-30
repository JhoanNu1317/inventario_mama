import 'package:flutter/material.dart';
import './info_producto_screen.dart';
import './productos_data.dart';
import 'producto_inventario.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  String _selectedCategory = categoriasInventario.first;

  List<ProductoInventario> getProductosPorCategoria(String categoria) {
    switch (categoria) {
      case 'Overhall':
        return productosOverhall;
      case 'Discos de fricción':
        return productosDiscosFriccion;
      case 'Bandas':
        return productosBandas;
      case 'Filtros':
        return productosFiltros;
      case 'Pistones':
        return productosPistones;
      case 'Retenedores':
        return productosRetenedores;
      case 'Bushing':
        return productosBushing;
      case 'Empaques':
        return productosEmpaques;
      case 'Discos sueltos':
        return productosDiscosSueltos;
      case 'Metales':
        return productosMetales;
      case 'Varios':
        return productosVarios;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final productos = getProductosPorCategoria(_selectedCategory);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCategory,
            dropdownColor: Colors.deepPurple[50],
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            selectedItemBuilder: (BuildContext context) {
              return categoriasInventario.map((String value) {
                return Center(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList();
            },
            items: categoriasInventario.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
            },
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: ListView.builder(
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
                            onTap: () {
                              setState(() {
                                if (producto.stock > 0) {
                                  producto.stock--;
                                }
                              });
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
                            child: Text('Categoría: ${producto.categoria}', style: const TextStyle(fontSize: 15, color: Colors.black54)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: producto.stock > 0 ? Colors.green[100] : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Stock: ${producto.stock}',
                              style: TextStyle(
                                fontSize: 15,
                                color: producto.stock > 0 ? Colors.green[800] : Colors.red[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (producto.precio != null && producto.precio.trim().isNotEmpty)
                          ? 'Precio: ${producto.precio}'
                          : 'Precio: Sin precio',
                        style: const TextStyle(fontSize: 15, color: Colors.deepPurple),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
