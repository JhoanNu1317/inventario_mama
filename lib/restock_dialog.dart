import 'package:flutter/material.dart';

Future<int?> showRestockDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();
  return showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Registrar restock'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Cantidad a agregar',
            hintText: 'Ingrese un número entero positivo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.of(context).pop(value);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese una cantidad válida (>0)')),
                );
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      );
    },
  );
}
