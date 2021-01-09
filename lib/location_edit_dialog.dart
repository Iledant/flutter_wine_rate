import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wine_rate/bloc/pick_regions.dart';
import 'constant.dart';
import 'models/location.dart';
import 'models/region.dart';
import 'disable_flat_button.dart';

class LocationEditDialog extends StatefulWidget {
  final DialogMode _mode;
  final Location _location;

  LocationEditDialog(this._mode, this._location, {Key key}) : super(key: key);

  @override
  _LocationEditDialogState createState() => _LocationEditDialogState();
}

class _LocationEditDialogState extends State<LocationEditDialog> {
  final _nameController = TextEditingController();
  final _regionController = TextEditingController();
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
    _regionController.dispose();
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
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.deepPurple[50],
              child: Column(children: [
                TextField(
                  controller: _regionController,
                  onChanged: (value) =>
                      BlocProvider.of<PickRegionsBloc>(context)
                          .add(PickRegionsLoaded(value)),
                  decoration: InputDecoration(
                    isDense: true,
                    icon: Icon(Icons.filter_alt_outlined, size: 16.0),
                  ),
                ),
                BlocBuilder<PickRegionsBloc, PickRegionsState>(
                    builder: (context, state) {
                  if (state is PickRegionsLoadFailure ||
                      state is PickRegionsLoadInProgress ||
                      state is PickRegionsEmpty) return SizedBox.shrink();
                  final regions = (state as PickRegionsLoadSuccess).regions;
                  return Card(
                    child: Column(
                      children: regions
                          .map(
                            (r) => InkWell(
                              onTap: () => setState(() {
                                _region = r;
                                _regionController.text = '';
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
                }),
              ]),
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

Future<Location> showEditLocationDialog(
    BuildContext context, Location location, DialogMode mode) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationEditDialog(mode, location));
}
