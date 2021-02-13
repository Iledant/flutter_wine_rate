import 'package:flutter/material.dart';

import 'constants.dart';
import 'models/region.dart';

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
          onChanged: (value) => setState(() => _disabled = value.isEmpty),
          autovalidateMode: AutovalidateMode.always,
          validator: (String value) =>
              value.isEmpty ? 'Le nom ne peut être vide' : null,
          decoration: const InputDecoration(hintText: 'Nom'),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        TextButton(
          child: Text(widget._mode == DialogMode.Edit ? 'Modifier' : 'Créer'),
          onPressed: _disabled
              ? null
              : () => Navigator.of(context)
                  .pop(Region(id: widget._region.id, name: _controller.text)),
        ),
      ],
    );
  }
}

Future<Region> showEditRegionDialog(
    BuildContext context, Region region, DialogMode mode) {
  if (region == null) region = Region(id: 0, name: '');
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RegionEditDialog(mode, region));
}
