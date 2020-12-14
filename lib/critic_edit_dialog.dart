import 'package:flutter/material.dart';
import 'package:flutter_wine_rate/constant.dart';
import 'package:flutter_wine_rate/models/critic.dart';

class CriticEditDialog extends StatefulWidget {
  final DialogMode _mode;
  final Critic _critic;

  CriticEditDialog(this._mode, this._critic, {Key key}) : super(key: key);

  @override
  _CriticEditDialogState createState() => _CriticEditDialogState();
}

class _CriticEditDialogState extends State<CriticEditDialog> {
  final _controller = TextEditingController();
  bool _disabled = false;

  void initState() {
    super.initState();
    _controller.text = widget._critic.name;
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
          onChanged: (value) {
            setState(() {
              _disabled = value.isEmpty;
            });
          },
          autovalidateMode: AutovalidateMode.always,
          controller: _controller,
          validator: (String value) =>
              value.isEmpty ? 'Le nom ne peut être vide' : null,
          decoration: InputDecoration(
            hintText: 'Nom',
          ),
        ),
      ),
      actions: [
        FlatButton(
          child: Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        IgnorePointer(
          ignoring: _disabled,
          child: FlatButton(
            textColor: _disabled ? Colors.grey : Theme.of(context).accentColor,
            child: Text(widget._mode == DialogMode.Edit ? 'Modifier' : 'Créer'),
            onPressed: () {
              if (_controller.text.isEmpty) return;
              Navigator.of(context)
                  .pop(Critic(id: widget._critic.id, name: _controller.text));
            },
          ),
        )
      ],
    );
  }
}
