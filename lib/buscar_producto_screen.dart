import 'package:flutter/material.dart';
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

  void _buscar() {
    final nombre = _nombreController.text.trim().toLowerCase();
    final categoria = _categoriaSeleccionada?.trim().toLowerCase();
    final apartado = _apartadoSeleccionado;
    List<ProductoInventario> resultados = [];

    if (apartado != null) {
      // Buscar solo en el apartado seleccionado
      resultados = _inventarios[apartado]!
        .where((p) =>
          (nombre.isEmpty || p.nombre.toLowerCase().contains(nombre)) &&
          (categoria == null || categoria.isEmpty || p.categoria.toLowerCase().contains(categoria))
        ).toList();
    } else {
      // Buscar en todos los apartados
      for (var lista in _inventarios.values) {
        resultados.addAll(lista.where((p) =>
          (nombre.isEmpty || p.nombre.toLowerCase().contains(nombre)) &&
          (categoria == null || categoria.isEmpty || p.categoria.toLowerCase().contains(categoria))
        ));
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
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Categoría (opcional)',
                border: OutlineInputBorder(),
              ),
              items: categorias.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _categoriaSeleccionada = value;
                });
              },
              isExpanded: true,
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
              onPressed: _buscar,
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
                            final apartado = mapApartado[p] ?? '';
                            return Card(
                              child: ListTile(
                                title: Text(p.nombre),
                                subtitle: Text('Categoría: \\${p.categoria}\nPrecio: \\${p.precio ?? ''}\nStock: \\${p.stock}\nInfo: \\${p.infoRelevante ?? ''}\nApartado: \\${apartado}'),
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
