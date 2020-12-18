import 'package:flutter/material.dart';
import 'package:flutter_wine_rate/constant.dart';
import 'package:flutter_wine_rate/models/region.dart';

class RegionEditDialog extends StatefulWidget {
  final DialogMode _mode;
  final Region _region;

  RegionEditDialog(this._mode, this._region, {Key key}) : super(key: key);

  @override
  _RegionEditDialogState createState() => _RegionEditDialogState();
}

class _RegionEditDialogState extends State<RegionEditDialog> {
  final _controller = TextEditingController();
  bool _disabled;

  void initState() {
    super.initState();
    _controller.text = widget._region.name;
    _disabled = widget._region.name.isEmpty;
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget._mode == DialogMode.Edit
          ? 'Modifier la Région'
          : 'Nouvelle région'),
      content: Form(
        child: TextFormField(
          controller: _controller,
          onChanged: (value) {
            setState(() {
              _disabled = value.isEmpty;
            });
          },
          autovalidateMode: AutovalidateMode.always,
          validator: (String value) =>
              value.isEmpty ? 'Le nom ne peut être vide' : null,
          decoration: InputDecoration(hintText: 'Nom'),
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
                  .pop(Region(id: widget._region.id, name: _controller.text));
            },
          ),
        ),
      ],
    );
  }
}
