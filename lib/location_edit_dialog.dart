import 'package:flutter/material.dart';
import 'package:flutter_wine_rate/filtered_menu.dart';
import 'package:flutter_wine_rate/redux/regions_state.dart';
import 'config.dart';
import 'constant.dart';
import 'models/location.dart';
import 'models/region.dart';
import 'disable_flat_button.dart';
import 'redux/store.dart';

class LocationEditDialog extends StatefulWidget {
  final DialogMode _mode;
  final Location _location;
  final Config _config;

  LocationEditDialog(this._mode, this._location, this._config, {Key key})
      : super(key: key);

  @override
  _LocationEditDialogState createState() => _LocationEditDialogState();
}

class _LocationEditDialogState extends State<LocationEditDialog> {
  final _nameController = TextEditingController();
  bool _disabled;
  Region _region;

  void initState() {
    super.initState();
    final Location location = widget._location;
    _nameController.text = location.name;
    _region = location.region != null
        ? Region(id: location.regionId, name: location.region)
        : null;
    _handleDisabled(location.name);
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
          onPressed: () => Navigator.of(context).pop(Location(
            id: widget._location.id,
            name: _nameController.text,
            regionId: _region.id,
            region: _region.name,
          )),
        ),
      ],
    );
  }
}
