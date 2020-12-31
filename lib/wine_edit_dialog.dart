import 'package:flutter/material.dart';
import 'package:flutter_wine_rate/filtered_menu.dart';
import 'package:flutter_wine_rate/redux/regions_state.dart';
import 'config.dart';
import 'constant.dart';
import 'models/domain.dart';
import 'models/location.dart';
import 'models/wine.dart';
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
  final _classificationController = TextEditingController();
  final _commentController = TextEditingController();
  bool _disabled;
  Domain _domain;
  Location _location;

  void initState() {
    super.initState();
    final Wine wine = widget._wine;
    _nameController.text = wine.name;
    _domain = wine.domain != null
        ? Domain(id: wine.domainId, name: wine.domain)
        : null;
    _location = wine.location != null
        ? Location(id: wine.locationId, name: wine.location)
        : null;
    _handleDisabled(wine.name);
  }

  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleDisabled(String nameValue) {
    _disabled = nameValue.isEmpty || _domain == null || _location == null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget._mode == DialogMode.Edit ? "Modifier le vin" : 'Nouveau vin'),
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
              decoration: InputDecoration(labelText: "Nom du vin"),
            ),
          ),
          SizedBox(height: 16.0),
          Form(
            child: TextFormField(
              controller: _classificationController,
              onChanged: (value) => setState(() => _handleDisabled(value)),
              decoration: InputDecoration(labelText: "Classement"),
            ),
          ),
          SizedBox(height: 16.0),
          Form(
            child: TextFormField(
              controller: _commentController,
              onChanged: (value) => setState(() => _handleDisabled(value)),
              decoration: InputDecoration(labelText: "Commentaire"),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            _domain == null ? 'Le domaine est obligatoire' : "Domaine",
            style: TextStyle(
                color: _domain != null
                    ? Theme.of(context).textTheme.caption.color
                    : Theme.of(context).errorColor,
                fontSize: Theme.of(context).textTheme.caption.fontSize),
          ),
          Text(
            (_domain != null ? _domain.name : '-'),
            style:
                TextStyle(color: _domain != null ? Colors.black : Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: FilteredMenu(
                fetchHook: (pattern) => Redux.store.dispatch((store) =>
                    fetchFirstFiveRegionsAction(
                        store, widget._config, pattern)),
                converter: (store) => store.state.domains.domains,
                onChanged: (domain) => setState(() {
                      _domain = domain;
                      _handleDisabled(_nameController.text);
                    }),
                valueDisplay: (domain) => domain.name),
          ),
          SizedBox(height: 16.0),
          Text(
            _domain == null ? "L'appellation est obligatoire" : "Appellation",
            style: TextStyle(
                color: _domain != null
                    ? Theme.of(context).textTheme.caption.color
                    : Theme.of(context).errorColor,
                fontSize: Theme.of(context).textTheme.caption.fontSize),
          ),
          Text(
            (_location != null ? _location.name : '-'),
            style:
                TextStyle(color: _location != null ? Colors.black : Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: FilteredMenu(
                fetchHook: (pattern) => Redux.store.dispatch((store) =>
                    fetchFirstFiveRegionsAction(
                        store, widget._config, pattern)),
                converter: (store) => store.state.locations.locations,
                onChanged: (location) => setState(() {
                      _location = location;
                      _handleDisabled(_nameController.text);
                    }),
                valueDisplay: (location) => location.name),
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
            classification: _classificationController.text,
            comment: _commentController.text,
            domainId: _domain.id,
            domain: _domain.name,
            locationId: _location.id,
            location: _location.name,
          )),
        ),
      ],
    );
  }
}
