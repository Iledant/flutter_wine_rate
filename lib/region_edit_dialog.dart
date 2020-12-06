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

  void initState() {
    super.initState();
    _controller.text = widget._region.name;
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
          decoration: InputDecoration(
            hintText: 'Recherche',
          ),
        ),
      ),
      actions: [
        FlatButton(
          child: Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        FlatButton(
          child: Text(widget._mode == DialogMode.Edit ? 'Modifier' : 'Annuler'),
          onPressed: () => Navigator.of(context)
              .pop(Region(widget._region.id, _controller.text)),
        ),
      ],
    );
  }
}
