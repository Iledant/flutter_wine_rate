import 'package:flutter/material.dart';
import 'package:flutter_wine_rate/filtered_menu.dart';
import 'package:flutter_wine_rate/redux/regions_state.dart';
import 'config.dart';
import 'constant.dart';
import 'models/wine.dart';
import 'models/region.dart';
import 'disable_flat_button.dart';
import 'redux/store.dart';

class WineEditDialog extends StatefulWidget {
  final DialogMode _mode;
  final Wine _wine;
  final Config _config;

  WineEditDialog(this._mode, this._wine, this._config, {Key key})
      : super(key: key);

  @override
  _WineEditDialogState createState() => _WineEditDialogState();
}

class _WineEditDialogState extends State<WineEditDialog> {
  final _nameController = TextEditingController();
  bool _disabled;
  Region _region;

  void initState() {
    super.initState();
    final Wine wine = widget._wine;
    _nameController.text = wine.name;
    _region = wine.region != null
        ? Region(id: wine.regionId, name: wine.region)
        : null;
    _handleDisabled(wine.name);
  }

  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleDisabled(String nameValue) {
    _disabled = nameValue.isEmpty || _region == null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget._mode == DialogMode.Edit
          ? "Modifier l'appellation"
          : 'Nouvelle appellation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            child: TextFormField(
              controller: _nameController,
              onChanged: (value) => setState(() => _handleDisabled(value)),
              autovalidateMode: AutovalidateMode.always,
              validator: (String value) =>
                  value.isEmpty ? 'Le nom ne peut être vide' : null,
              decoration: InputDecoration(labelText: "Nom de l'appellation"),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            _region == null
                ? 'La région ne peut pas être vide'
                : "Région d'appartenance",
            style: TextStyle(
                color: _region != null
                    ? Theme.of(context).textTheme.caption.color
                    : Theme.of(context).errorColor,
                fontSize: Theme.of(context).textTheme.caption.fontSize),
          ),
          Text(
            (_region != null ? _region.name : '-'),
            style:
                TextStyle(color: _region != null ? Colors.black : Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: FilteredMenu(
                fetchHook: (pattern) => Redux.store.dispatch((store) =>
                    fetchFirstFiveRegionsAction(
                        store, widget._config, pattern)),
                converter: (store) => store.state.regions.regions,
                onChanged: (region) => setState(() {
                      _region = region;
                      _handleDisabled(_nameController.text);
                    }),
                valueDisplay: (region) => region.name),
          )
        ],
      ),
      actions: [
        FlatButton(
          child: Text('Annuler'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        DisableFlatButton(
          disabled: _disabled,
          text: widget._mode == DialogMode.Edit ? 'Modifier' : 'Créer',
          onPressed: () => Navigator.of(context).pop(Wine(
            id: widget._wine.id,
            name: _nameController.text,
            regionId: _region.id,
            region: _region.name,
          )),
        ),
      ],
    );
  }
}
