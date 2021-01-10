import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/pick_domains.dart';
import 'bloc/pick_locations.dart';
import 'constant.dart';
import 'models/wine.dart';
import 'models/location.dart';
import 'models/domain.dart';
import 'disable_flat_button.dart';

class WineEditDialog extends StatefulWidget {
  final DialogMode _mode;
  final Wine _wine;

  WineEditDialog(this._mode, this._wine, {Key key}) : super(key: key);

  @override
  _WineEditDialogState createState() => _WineEditDialogState();
}

class _WineEditDialogState extends State<WineEditDialog> {
  final _nameController = TextEditingController();
  final _classificationController = TextEditingController();
  final _commentController = TextEditingController();
  final _locationController = TextEditingController();
  final _domainController = TextEditingController();
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
        ? Location(
            id: wine.locationId,
            name: wine.location,
            regionId: wine.regionId,
            region: wine.region,
          )
        : null;
    _handleDisabled(wine.name);
  }

  void dispose() {
    _nameController.dispose();
    _classificationController.dispose();
    _commentController.dispose();
    _locationController.dispose();
    _domainController.dispose();
    super.dispose();
  }

  void _handleDisabled(String nameValue) {
    _disabled = nameValue.isEmpty || _domain == null || _location == null;
  }

  Widget popupMenu<T>(
      List<T> lines, void Function(T) setState, String Function(T) getText) {
    return Card(
      child: Column(
        children: lines
            .map(
              (r) => InkWell(
                onTap: () => setState(r),
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(4.0),
                  child: Text(getText(r)),
                ),
              ),
            )
            .toList(),
      ),
      elevation: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget._mode == DialogMode.Edit ? "Modifier le vin" : 'Nouveau vin'),
      scrollable: true,
      content: Column(
        children: [
          Form(
            child: TextFormField(
              autofocus: true,
              controller: _nameController,
              onChanged: (value) => setState(() => _handleDisabled(value)),
              autovalidateMode: AutovalidateMode.always,
              validator: (String value) =>
                  value.isEmpty ? 'Le nom ne peut être vide' : null,
              decoration: InputDecoration(labelText: "Nom du vin"),
            ),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _classificationController,
            onChanged: (value) => setState(() => _handleDisabled(value)),
            decoration: InputDecoration(labelText: "Classement"),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _commentController,
            onChanged: (value) => setState(() => _handleDisabled(value)),
            decoration: InputDecoration(labelText: "Commentaire"),
          ),
          SizedBox(height: 16.0),
          Text(
            _domain == null
                ? 'Le domaine ne peut pas être vide'
                : "Domaine d'appartenance",
            style: TextStyle(
                color: _domain != null
                    ? Theme.of(context).textTheme.caption.color
                    : Theme.of(context).errorColor,
                fontSize: Theme.of(context).textTheme.caption.fontSize),
          ),
          Text(
            _domain?.name ?? '-',
            style:
                TextStyle(color: _domain != null ? Colors.black : Colors.red),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.deepPurple[50],
              child: Column(children: [
                TextField(
                  controller: _domainController,
                  onChanged: (value) =>
                      BlocProvider.of<PickDomainsBloc>(context)
                          .add(PickDomainsLoaded(value)),
                  decoration: InputDecoration(
                    isDense: true,
                    icon: Icon(Icons.filter_alt_outlined, size: 16.0),
                  ),
                ),
                BlocBuilder<PickDomainsBloc, PickDomainsState>(
                    builder: (context, state) {
                  if (state is PickDomainsLoadFailure ||
                      state is PickDomainsLoadInProgress ||
                      state is PickDomainsEmpty) return SizedBox.shrink();
                  final domains = (state as PickDomainsLoadSuccess).domains;
                  return popupMenu(
                      domains,
                      (domain) => setState(() {
                            _domain = domain;
                            _domainController.text = '';
                            BlocProvider.of<PickDomainsBloc>(context)
                                .add(PickDomainsClear());
                          }),
                      (domain) => domain.name);
                }),
              ]),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            _location == null
                ? "L'appellation ne peut pas être vide"
                : "Appellation d'appartenance",
            style: TextStyle(
                color: _location != null
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
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.deepPurple[50],
              child: Column(children: [
                TextField(
                  controller: _locationController,
                  onChanged: (value) =>
                      BlocProvider.of<PickLocationsBloc>(context)
                          .add(PickLocationsLoaded(value)),
                  decoration: InputDecoration(
                    isDense: true,
                    icon: Icon(Icons.filter_alt_outlined, size: 16.0),
                  ),
                ),
                BlocBuilder<PickLocationsBloc, PickLocationsState>(
                    builder: (context, state) {
                  if (state is PickLocationsLoadFailure ||
                      state is PickLocationsLoadInProgress ||
                      state is PickLocationsEmpty) {
                    return SizedBox.shrink();
                  }
                  final locations =
                      (state as PickLocationsLoadSuccess).locations;
                  return popupMenu(
                      locations,
                      (location) => setState(() {
                            _location = location;
                            _locationController.text = '';
                            BlocProvider.of<PickLocationsBloc>(context)
                                .add(PicklocationsClear());
                          }),
                      (location) => location.name);
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
          onPressed: () => Navigator.of(context).pop(Wine(
              id: widget._wine.id,
              name: _nameController.text,
              classification: _classificationController.text.isEmpty
                  ? null
                  : _classificationController.text,
              comment: _commentController.text.isEmpty
                  ? null
                  : _commentController.text,
              domainId: _domain.id,
              domain: _domain.name,
              locationId: _location.id,
              location: _location.name,
              regionId: _location.regionId,
              region: _location.region)),
        ),
      ],
    );
  }
}

Future<Wine> showEditWineDialog(
    BuildContext context, Wine wine, DialogMode mode) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WineEditDialog(mode, wine));
}
