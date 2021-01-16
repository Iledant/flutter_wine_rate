import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  final String objectKind;
  final String objectName;

  DeleteDialog({@required this.objectKind, @required this.objectName, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Supprimer $objectKind '$objectName' ?"),
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

Future<bool> showDeleteDialog(
    BuildContext context, String objectKind, objectName) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => DeleteDialog(
      objectKind: objectKind,
      objectName: objectName,
    ),
  );
}
