import 'package:flutter/material.dart';

import 'constants.dart';
import 'models/domain.dart';

class DomainEditDialog extends StatefulWidget {
  final DialogMode _mode;
  final Domain _domain;

  DomainEditDialog(this._mode, this._domain, {Key key}) : super(key: key);

  @override
  _DomainEditDialogState createState() => _DomainEditDialogState();
}

class _DomainEditDialogState extends State<DomainEditDialog> {
  final _controller = TextEditingController();
  bool _disabled;

  void initState() {
    super.initState();
    _controller.text = widget._domain.name;
    _disabled = widget._domain.name.isEmpty;
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget._mode == DialogMode.Edit
          ? 'Modifier le domaine'
          : 'Nouveau domaine'),
      content: Form(
        child: TextFormField(
          controller: _controller,
          onChanged: (text) => setState(() => _disabled = text.isEmpty),
          autovalidateMode: AutovalidateMode.always,
          validator: (String value) =>
              value.isEmpty ? 'Le nom ne peut être vide' : null,
          decoration: const InputDecoration(hintText: 'Nom'),
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
                  .pop(Domain(id: widget._domain.id, name: _controller.text)),
        )
      ],
    );
  }
}

Future<Domain> showEditDomainDialog(
    BuildContext context, Domain domain, DialogMode mode) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DomainEditDialog(mode, domain));
}
