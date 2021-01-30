import 'package:flutter/material.dart';

import 'constants.dart';
import 'models/critic.dart';

class CriticEditDialog extends StatefulWidget {
  final DialogMode _mode;
  final Critic _critic;

  CriticEditDialog(this._mode, this._critic, {Key key}) : super(key: key);

  @override
  _CriticEditDialogState createState() => _CriticEditDialogState();
}

class _CriticEditDialogState extends State<CriticEditDialog> {
  final _controller = TextEditingController();
  bool _disabled;

  void initState() {
    super.initState();
    _controller.text = widget._critic.name;
    _disabled = widget._critic.name.isEmpty;
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget._mode == DialogMode.Edit
          ? 'Modifier le critique'
          : 'Nouveau critique'),
      content: Form(
        child: TextFormField(
          controller: _controller,
          onChanged: (value) {
            setState(() => {_disabled = _controller.text.isEmpty});
          },
          autovalidateMode: AutovalidateMode.always,
          validator: (String value) =>
              value.isEmpty ? 'Le nom ne peut être vide' : null,
          decoration: InputDecoration(hintText: 'Nom'),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        TextButton(
          child: Text(widget._mode == DialogMode.Edit ? 'Modifier' : 'Créer'),
          onPressed: _disabled
              ? null
              : () => Navigator.of(context)
                  .pop(Critic(id: widget._critic.id, name: _controller.text)),
        ),
      ],
    );
  }
}

Future<Critic> showEditCriticDialog(
    BuildContext context, Critic critic, DialogMode mode) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CriticEditDialog(mode, critic));
}
