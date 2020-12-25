import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
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
  final _regionController = TextEditingController();
  bool _disabled;
  Region _region;
  Timer _debounce;

  void initState() {
    super.initState();
    _nameController.text = widget._location.name;
    _disabled = widget._location.name.isEmpty;
    _region =
        Region(id: widget._location.regionId, name: widget._location.region);
    _regionController.text = _region.name;
    Redux.store.dispatch((store) => fetchFirstFiveRegionsAction(
        store, widget._config, widget._location.region));
  }

  void dispose() {
    _nameController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _debounceSearch(String pattern) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        Redux.store.dispatch((store) =>
            fetchFirstFiveRegionsAction(store, widget._config, pattern));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget._mode == DialogMode.Edit
          ? 'Modifier la Région'
          : 'Nouvelle région'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            child: TextFormField(
              controller: _nameController,
              onChanged: (value) {
                setState(() => _disabled = value.isEmpty);
              },
              autovalidateMode: AutovalidateMode.always,
              validator: (String value) =>
                  value.isEmpty ? 'Le nom ne peut être vide' : null,
              decoration: InputDecoration(hintText: 'Appellation'),
            ),
          ),
          Form(
            child: TextFormField(
              controller: _regionController,
              onChanged: (value) => _debounceSearch(value),
              autovalidateMode: AutovalidateMode.always,
              validator: (_) => _region == null ? 'Région à préciser' : null,
              decoration: InputDecoration(
                labelText: 'Région : ' + (_region != null ? _region.name : '-'),
                icon: Icon(Icons.filter_alt_outlined),
              ),
            ),
          ),
          StoreConnector<AppState, List<Region>>(
            distinct: true,
            converter: (store) => store.state.regions.regions,
            builder: (context, regions) {
              if (regions.length == 0) return SizedBox.shrink();
              return Card(
                child: Column(
                  children: regions
                      .map(
                        (r) => InkWell(
                          onTap: () => setState(() {
                            _region = r;
                          }),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(4.0),
                            child: Text(r.name),
                          ),
                        ),
                      )
                      .toList(),
                ),
                elevation: 2.0,
              );
            },
          ),
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
