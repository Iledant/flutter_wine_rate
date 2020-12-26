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
  bool _showSuggestions;
  Region _region;
  Timer _debounce;

  void initState() {
    super.initState();
    _nameController.text = widget._location.name;
    _disabled = widget._location.name.isEmpty;
    _region =
        Region(id: widget._location.regionId, name: widget._location.region);
    Redux.store.dispatch(
        (store) => fetchFirstFiveRegionsAction(store, widget._config, ''));
    _showSuggestions = false;
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
        _showSuggestions = true;
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(height: 16.0),
          Text('Région : ' + (_region != null ? _region.name : '-')),
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.grey[100],
            child: Column(
              children: [
                TextField(
                  controller: _regionController,
                  onChanged: (value) => _debounceSearch(value),
                  decoration: InputDecoration(
                    isDense: true,
                    icon: Icon(
                      Icons.filter_alt_outlined,
                      size: 16.0,
                    ),
                  ),
                ),
                StoreConnector<AppState, List<Region>>(
                  distinct: true,
                  converter: (store) => store.state.regions.regions,
                  builder: (context, regions) {
                    if (regions.length == 0 || !_showSuggestions)
                      return SizedBox.shrink();
                    return Card(
                      child: Column(
                        children: regions
                            .map(
                              (r) => InkWell(
                                onTap: () => setState(() {
                                  _region = r;
                                  _showSuggestions = false;
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
