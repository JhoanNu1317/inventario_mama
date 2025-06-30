class ProductoInventario {
  final String nombre;
  final String categoria;
  int stock;
  final String precio;
  final String infoRelevante;

  ProductoInventario({
    required this.nombre,
    required this.categoria,
    required this.stock,
    required this.precio,
    this.infoRelevante = '',
  });
}
