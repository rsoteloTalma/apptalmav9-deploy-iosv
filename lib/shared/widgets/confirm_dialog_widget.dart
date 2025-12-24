import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  String title = "Confirmación",
  String message = "¿Estás seguro?",
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text(
              "Aceptar",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
