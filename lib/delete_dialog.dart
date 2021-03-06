import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  final String name;

  DeleteDialog({@required this.name, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Supprimer l'élément '$name' ?"),
      actions: [
        TextButton(
          child: Text('Non'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text('Oui'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}

Future<bool> showDeleteDialog(BuildContext context, String name) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => DeleteDialog(name: name),
  );
}
