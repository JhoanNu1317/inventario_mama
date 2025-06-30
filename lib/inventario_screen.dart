import 'package:flutter/material.dart';
import './info_producto_screen.dart';
import './productos_data.dart';
import 'producto_inventario.dart';
import 'restock_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'editar_producto_screen.dart';

class InventarioScreen extends StatefulWidget {
  final String? initialApartado;
  final String? initialCategoria;
  final String? highlightNombre;

  const InventarioScreen({
    super.key,
    this.initialApartado,
    this.initialCategoria,
    this.highlightNombre,
  });

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  String _selectedCategory = categoriasInventario.first;
  bool _cargandoFirestore = true;

  // Mapeo de nombre de categoría a nombre de colección en Firestore
  final Map<String, String> _categoriaToColeccion = {
    'Overhall': 'overhall',
    'Discos de fricción': 'discos_friccion',
    'Bandas': 'bandas',
    'Filtros': 'filtros',
    'Pistones': 'pistones',
    'Retenedores': 'retenedores',
    'Bushing': 'bushing',
    'Empaques': 'empaques',
    'Discos sueltos': 'discos_sueltos',
    'Metales': 'metales',
    'Varios': 'varios',
  };

  // 1. Agregar variables para scroll y producto a resaltar
  ScrollController? _scrollController;
  String? _highlightNombre;
  String? _highlightCategoria;
  int? _pendingScrollToIndex;
  bool _hasScrolled = false;
  int? _selectedIndex; // Para saber qué producto está expandido

  @override
  void initState() {
    super.initState();
    // 2. Leer parámetros iniciales
    _highlightNombre = widget.highlightNombre;
    _highlightCategoria = widget.initialCategoria;
    // Si initialApartado está presente y es válido, seleccionarlo como categoría
    if (widget.initialApartado != null && categoriasInventario.contains(widget.initialApartado)) {
      _selectedCategory = widget.initialApartado!;
    } else if (widget.initialCategoria != null && categoriasInventario.contains(widget.initialCategoria)) {
      _selectedCategory = widget.initialCategoria!;
    }
    _scrollController = ScrollController();
    // Sincronización automática desactivada (eliminar llamadas de prueba)
    // sincronizarColeccionSinBorrar('overhall', productosOverhall);
    // sincronizarColeccionSinBorrar('discos_friccion', productosDiscosFriccion);
    // sincronizarColeccionSinBorrar('bandas', productosBandas);
    // sincronizarColeccionSinBorrar('varios', productosVarios);
    // sincronizarColeccionSinBorrar('discos_sueltos', productosDiscosSueltos);
    // sincronizarColeccionSinBorrar('pistones', productosPistones);
    // sincronizarColeccionSinBorrar('filtros', productosFiltros);
    // sincronizarColeccionSinBorrar('retenedores', productosRetenedores);
    // sincronizarColeccionSinBorrar('metales', productosMetales);
    // sincronizarColeccionSinBorrar('empaques', productosEmpaques);
    // sincronizarColeccionSinBorrar('bushing', productosBushing);
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  Future<void> sincronizarColeccionSinBorrar(String coleccion, List<ProductoInventario> productos) async {
    final collectionRef = FirebaseFirestore.instance.collection(coleccion);
    final snapshot = await collectionRef.get();
    final docs = snapshot.docs;
    for (var producto in productos) {
      QueryDocumentSnapshot<Map<String, dynamic>>? existe;
      for (var doc in docs) {
        if (doc['nombre'] == producto.nombre && doc['categoria'] == producto.categoria) {
          existe = doc;
          break;
        }
      }
      if (existe == null) {
        // Si no existe, lo agregamos con el stock local
        await collectionRef.add({
          'nombre': producto.nombre,
          'categoria': producto.categoria,
          'stock': producto.stock,
          'precio': producto.precio,
          'infoRelevante': producto.infoRelevante,
        });
      } else {
        // Si existe, actualizamos solo los campos que no son stock
        await existe.reference.update({
          'nombre': producto.nombre,
          'categoria': producto.categoria,
          'precio': producto.precio,
          'infoRelevante': producto.infoRelevante,
        });
      }
    }
  }

  Stream<List<ProductoInventario>> streamProductosCategoria(String coleccion) {
    return FirebaseFirestore.instance
        .collection(coleccion)
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

  Future<void> actualizarStockFirestore(String nombre, String categoria, int nuevoStock, {required String coleccion}) async {
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
    final coleccionActual = _categoriaToColeccion[_selectedCategory]!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _selectedCategory,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _selectedCategory,
              dropdownColor: Colors.deepPurple[50],
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              underline: Container(),
              style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 18),
              items: categoriasInventario.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat, style: const TextStyle(color: Colors.deepPurple)),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: StreamBuilder<List<ProductoInventario>>(
          stream: streamProductosCategoria(coleccionActual),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            }
            final productos = snapshot.data ?? [];
            if (productos.isEmpty) {
              return Center(child: Text('No hay productos en \\${_selectedCategory}.'));
            }
            return _buildProductosList(productos, coleccionActual);
          },
        ),
      ),
    );
  }

  Widget _buildProductosList(List<ProductoInventario> productos, String coleccion) {
    int highlightIndex = -1;
    if (_highlightNombre != null) {
      highlightIndex = productos.indexWhere((p) =>
        p.nombre.toLowerCase() == _highlightNombre!.toLowerCase() &&
        (_highlightCategoria == null || p.categoria == _highlightCategoria)
      );
    }
    // Guardar el índice para hacer scroll después
    if (!_hasScrolled && highlightIndex >= 0) {
      _pendingScrollToIndex = highlightIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController != null && _scrollController!.hasClients && _pendingScrollToIndex != null) {
          _scrollController!.animateTo(
            _pendingScrollToIndex! * 120.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          _hasScrolled = true;
        }
      });
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        final isHighlighted = _highlightNombre != null &&
          producto.nombre.toLowerCase() == _highlightNombre!.toLowerCase() &&
          (_highlightCategoria == null || producto.categoria == _highlightCategoria);
        return Card(
          color: isHighlighted ? Colors.yellow[200] : null,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: Text(producto.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Categoría: \\${producto.categoria}', style: const TextStyle(fontSize: 15, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text((producto.precio != null && producto.precio.trim().isNotEmpty)
                          ? 'Precio: \\${producto.precio}'
                          : 'Precio: Sin precio',
                          style: const TextStyle(fontSize: 15, color: Colors.deepPurple)),
                        const SizedBox(height: 8),
                        Container(
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
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.info_outline, color: Colors.deepPurple),
                              tooltip: 'Ver info',
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InfoProductoScreen(
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
                            IconButton(
                              icon: const Icon(Icons.remove_shopping_cart, color: Colors.orange),
                              tooltip: 'Se vendió',
                              onPressed: () async {
                                Navigator.pop(context);
                                if (producto.stock > 0) {
                                  await actualizarStockFirestore(producto.nombre, producto.categoria, producto.stock - 1, coleccion: coleccion);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('¡Producto vendido!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No hay stock disponible.')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueGrey),
                              tooltip: 'Editar',
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditarProductoScreen(producto: producto, coleccion: coleccion),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  );
                },
              );
            },
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
                            await actualizarStockFirestore(producto.nombre, producto.categoria, nuevoStock, coleccion: coleccion);
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
                  if ((producto.infoRelevante != null && producto.infoRelevante.trim().isNotEmpty))
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.deepPurple, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              producto.infoRelevante,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
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