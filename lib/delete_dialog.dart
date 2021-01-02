import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  final String objectKind;
  final String objectName;

  DeleteDialog({@required this.objectKind, @required this.objectName, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Supprimer $objectKind ?'),
      content: Text("Le critique supprimé serait '$objectName'"),
      actions: [
        FlatButton(
          child: Text('Non'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        FlatButton(
          child: Text('Oui'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
