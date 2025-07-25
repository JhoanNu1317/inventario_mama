import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'producto_inventario.dart';
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
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';

class ProformaScreen extends StatefulWidget {
  const ProformaScreen({Key? key}) : super(key: key);

  @override
  State<ProformaScreen> createState() => _ProformaScreenState();
}

class _ProformaScreenState extends State<ProformaScreen> {
  final TextEditingController _clienteController = TextEditingController();
  final DateTime _fecha = DateTime.now();
  final List<_ProformaItem> _items = [];

  void _agregarItem() async {
    final item = await showDialog<_ProformaItem>(
      context: context,
      builder: (context) => _AgregarItemDialog(),
    );
    if (item != null) {
      setState(() {
        _items.add(item);
      });
    }
  }

  // Calcular subtotal y total con IVA
  double get _subtotal {
    return _items.fold(0, (sum, item) => sum + item.total);
  }
  double get _iva => _subtotal * 0.13;
  double get _totalConIva => _subtotal + _iva;

  @override
  void dispose() {
    _clienteController.dispose();
    super.dispose();
  }

  Future<Uint8List> _generarPdf() async {
    final pdf = pw.Document();
    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'));
    final logo = await rootBundle.load('assets/logo.png');
    final image = pw.MemoryImage(logo.buffer.asUint8List());
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 80,
                    height: 80,
                    child: pw.Image(image),
                  ),
                  pw.SizedBox(width: 16),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Proforma', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: font)),
                      pw.Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_fecha)}', style: pw.TextStyle(font: font)),
                      pw.Text('Cliente:  ${_clienteController.text}', style: pw.TextStyle(font: font)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFEDE7F6)),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text('Descripción', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text('Cantidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text('Precio', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font)),
                      ),
                    ],
                  ),
                  ..._items.map((item) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(item.descripcion, style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(item.cantidad.toString(), style: pw.TextStyle(font: font)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(item.precio, style: pw.TextStyle(font: font)),
                      ),
                    ],
                  )),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: ₡${_subtotal.toStringAsFixed(2)}', style: pw.TextStyle(font: font)),
                      pw.Text('IVA 13%: ₡${_iva.toStringAsFixed(2)}', style: pw.TextStyle(font: font)),
                      pw.Text('Total: ₡${_totalConIva.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(_fecha);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Proforma'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _clienteController,
                    decoration: const InputDecoration(
                      labelText: 'Cliente',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Fecha:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(dateStr),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Cabecera
            Row(
              children: const [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('DESCRIPCIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: Center(child: Text('CANT.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                ),
                SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('PRECIO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                SizedBox(width: 40), // Espacio para el botón eliminar
              ],
            ),
            const Divider(),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('Agrega productos a la proforma'))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (context, i) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final item = _items[i];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(item.descripcion, style: const TextStyle(fontSize: 15)),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 80,
                                  child: Center(child: Text(item.cantidad.toString(), style: const TextStyle(fontSize: 15))),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 100,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(item.precio, style: const TextStyle(fontSize: 15)),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() { _items.removeAt(i); });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            // Reemplazar el widget de Total por el desglose
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Text('Subtotal: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('₡${_subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('IVA 13%: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('₡${_iva.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Total: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('₡${_totalConIva.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Agregar producto a proforma'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: _agregarItem,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar/Compartir PDF'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              onPressed: () async {
                final pdfData = await _generarPdf();
                await Printing.sharePdf(bytes: pdfData, filename: 'proforma.pdf');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProformaItem {
  final String descripcion;
  final int cantidad;
  final String precio;
  double get total {
    final num = double.tryParse(precio.replaceAll('₡', '').replaceAll(',', '')) ?? 0;
    return cantidad * num;
  }
  _ProformaItem({required this.descripcion, required this.cantidad, required this.precio});
}

class _AgregarItemDialog extends StatefulWidget {
  @override
  State<_AgregarItemDialog> createState() => _AgregarItemDialogState();
}

class _AgregarItemDialogState extends State<_AgregarItemDialog> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _cantController = TextEditingController(text: '1');
  final TextEditingController _precioController = TextEditingController();

  String? _apartadoSeleccionado;
  ProductoInventario? _productoSeleccionado;

  final List<String> apartados = [
    'Overhall', 'Discos de fricción', 'Bandas', 'Filtros', 'Pistones', 'Retenedores', 'Bushing', 'Empaques', 'Discos sueltos', 'Metales', 'Varios',
  ];

  Future<List<ProductoInventario>> _buscarProductosFirestore(String query) async {
    final apartadosFirestore = [
      'overhall', 'discos_friccion', 'bandas', 'filtros', 'pistones', 'retenedores', 'bushing', 'empaques', 'discos_sueltos', 'metales', 'varios',
    ];
    List<ProductoInventario> productos = [];
    for (final col in apartadosFirestore) {
      if (_apartadoSeleccionado != null && col != _apartadoSeleccionado!.toLowerCase().replaceAll(' ', '_')) continue;
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
        if (query.isEmpty ||
            p.nombre.toLowerCase().contains(query.toLowerCase()) ||
            p.categoria.toLowerCase().contains(query.toLowerCase())) {
          productos.add(p);
        }
      }
    }
    return productos;
  }

  @override
  void dispose() {
    _descController.dispose();
    _cantController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar producto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _apartadoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Filtrar por apartado',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('Todos los apartados')),
                ...apartados.map((apart) => DropdownMenuItem(
                  value: apart,
                  child: Text(apart),
                ))
              ],
              onChanged: (value) {
                setState(() {
                  _apartadoSeleccionado = value;
                });
              },
              isExpanded: true,
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<ProductoInventario>>(
              future: _buscarProductosFirestore(''),
              builder: (context, snapshot) {
                return Autocomplete<ProductoInventario>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    final productos = await _buscarProductosFirestore(textEditingValue.text);
                    return productos;
                  },
                  displayStringForOption: (p) => '${p.nombre} (${p.categoria})',
                  fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(labelText: 'Buscar producto'),
                      onEditingComplete: onEditingComplete,
                    );
                  },
                  onSelected: (ProductoInventario selection) {
                    setState(() {
                      _productoSeleccionado = selection;
                      _descController.text = '${selection.nombre} (${selection.categoria})';
                      _precioController.text = selection.precio;
                    });
                  },
                );
              },
            ),
            if (_productoSeleccionado != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categoría: ${_productoSeleccionado!.categoria}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if ((_productoSeleccionado!.infoRelevante ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Info: ${_productoSeleccionado!.infoRelevante}', style: const TextStyle(color: Colors.black87)),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: _cantController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(labelText: 'Precio (₡)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final desc = _descController.text.trim();
            final cant = int.tryParse(_cantController.text.trim()) ?? 1;
            String precio = _precioController.text.trim();
            if (precio.isNotEmpty && !precio.startsWith('₡')) {
              precio = '₡' + precio;
            }
            if (desc.isNotEmpty && precio.isNotEmpty) {
              Navigator.pop(context, _ProformaItem(descripcion: desc, cantidad: cant, precio: precio));
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}
