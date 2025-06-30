import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'data/overhall.dart';
import 'data/discos_de_friccion.dart';
import 'data/bandas.dart';
import 'data/filtros.dart';
import 'data/pistones.dart';
import 'data/retenedores.dart';
import 'data/bushing.dart';
import 'data/empaques.dart';
import 'data/discos_sueltos.dart';
import 'data/metales.dart';
import 'data/varios.dart';
import 'producto_inventario.dart';
import 'inventario_screen.dart';

class BuscarProductoScreen extends StatefulWidget {
  const BuscarProductoScreen({Key? key}) : super(key: key);

  @override
  State<BuscarProductoScreen> createState() => _BuscarProductoScreenState();
}

class _BuscarProductoScreenState extends State<BuscarProductoScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  String? _categoriaSeleccionada;
  String? _apartadoSeleccionado;
  List<ProductoInventario> _resultados = [];
  bool _buscado = false;

  final List<String> categorias = [
    'Transna', 'Accord', 'Precisión', 'Americano', 'Nada', 'ALLOMA', 'ALLOMATIC', 'RAYBESTO', 'PRADO', 'AMERICANO', 'TRANSNA', 'ALLO', 'ALLOMA', 'ALLOMATIC', 'RAYBESTO', 'PRADO', 'AMERICANO', 'TRANSNA', 'ALLO',
  ];

  final List<String> apartados = [
    'Overhall', 'Discos de fricción', 'Bandas', 'Filtros', 'Pistones', 'Retenedores', 'Bushing', 'Empaques', 'Discos sueltos', 'Metales', 'Varios',
  ];

  Map<String, List<ProductoInventario>> get _inventarios => {
    'Overhall': productosOverhall,
    'Discos de fricción': productosDiscosFriccion,
    'Bandas': productosBandas,
    'Filtros': productosFiltros,
    'Pistones': productosPistones,
    'Retenedores': productosRetenedores,
    'Bushing': productosBushing,
    'Empaques': productosEmpaques,
    'Discos sueltos': productosDiscosSueltos,
    'Metales': productosMetales,
    'Varios': productosVarios,
  };

  Stream<List<Map<String, dynamic>>> _streamTodosProductos() async* {
    final apartadosFirestore = [
      'overhall', 'discos_friccion', 'bandas', 'filtros', 'pistones', 'retenedores', 'bushing', 'empaques', 'discos_sueltos', 'metales', 'varios',
    ];
    while (true) {
      List<Map<String, dynamic>> productos = [];
      for (final col in apartadosFirestore) {
        final snap = await FirebaseFirestore.instance.collection(col).get();
        for (final doc in snap.docs) {
          final data = doc.data();
          data['apartado'] = col;
          productos.add(data);
        }
      }
      yield productos;
      await Future.delayed(const Duration(seconds: 2)); // refresco cada 2s
    }
  }

  void _buscarFirestore() async {
    final nombre = _nombreController.text.trim().toLowerCase();
    final categoria = _categoriaSeleccionada?.trim().toLowerCase();
    final apartado = _apartadoSeleccionado;
    final apartadosFirestore = [
      'overhall', 'discos_friccion', 'bandas', 'filtros', 'pistones', 'retenedores', 'bushing', 'empaques', 'discos_sueltos', 'metales', 'varios',
    ];
    List<ProductoInventario> resultados = [];
    for (final col in apartadosFirestore) {
      if (apartado != null && col != apartado.toLowerCase().replaceAll(' ', '_')) continue;
      final snap = await FirebaseFirestore.instance.collection(col).get();
      for (final doc in snap.docs) {
        final data = doc.data();
        final p = ProductoInventario(
          nombre: data['nombre'] ?? '',
          categoria: data['categoria'] ?? '',
          stock: data['stock'] ?? 0,
          precio: data['precio'] ?? '',
          infoRelevante: data['infoRelevante'] ?? '',
        );
        if ((nombre.isEmpty || p.nombre.toLowerCase().contains(nombre)) &&
            (categoria == null || categoria.isEmpty || p.categoria.toLowerCase().contains(categoria))) {
          resultados.add(p);
        }
      }
    }
    setState(() {
      _resultados = resultados;
      _buscado = true;
    });
  }

  Map<ProductoInventario, String> _apartadoDeProducto(List<ProductoInventario> resultados) {
    final map = <ProductoInventario, String>{};
    _inventarios.forEach((apartado, lista) {
      for (var p in resultados) {
        if (lista.contains(p)) {
          map[p] = apartado;
        }
      }
    });
    return map;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar producto'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<String>.empty();
                }
                return categorias.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                _categoriaController.text = controller.text;
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Categoría (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  onEditingComplete: onEditingComplete,
                );
              },
              onSelected: (String selection) {
                _categoriaController.text = selection;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _apartadoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Apartado (opcional)',
                border: OutlineInputBorder(),
              ),
              items: apartados.map((apart) => DropdownMenuItem(
                value: apart,
                child: Text(apart),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _apartadoSeleccionado = value;
                });
              },
              isExpanded: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _categoriaSeleccionada = _categoriaController.text;
                });
                _buscarFirestore();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 24),
            if (_buscado)
              Expanded(
                child: _resultados.isEmpty
                  ? const Center(child: Text('No se encontraron productos.'))
                  : Builder(
                      builder: (context) {
                        final mapApartado = _apartadoDeProducto(_resultados);
                        return ListView.builder(
                          itemCount: _resultados.length,
                          itemBuilder: (context, i) {
                            final p = _resultados[i];
                            // Buscar el apartado por coincidencia de nombre y categoría si no está en el map
                            String apartado = mapApartado[p] ?? '';
                            if (apartado.isEmpty) {
                              _inventarios.forEach((key, lista) {
                                if (lista.any((prod) => prod.nombre == p.nombre && prod.categoria == p.categoria)) {
                                  apartado = key;
                                }
                              });
                            }
                            return Card(
                              child: ListTile(
                                title: Text(p.nombre),
                                subtitle: Text(
                                  'Categoría: \\${p.categoria}\nPrecio: \\${p.precio ?? ''}\nStock: \\${p.stock}\nInfo: \\${p.infoRelevante ?? ''}\nApartado: \\${apartado.isNotEmpty ? apartado : 'Desconocido'}',
                                ),
                                trailing: apartado.isNotEmpty
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          apartado,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InventarioScreen(
                                        initialApartado: apartado,
                                        initialCategoria: p.categoria,
                                        highlightNombre: p.nombre,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
