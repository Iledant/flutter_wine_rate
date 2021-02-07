import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers/domain_provider.dart';
import 'constants.dart';
import 'models/pagination.dart';
import 'models/wine.dart';
import 'models/location.dart';
import 'models/domain.dart';
import 'providers/location_provider.dart';
import 'screen_widget.dart';

class WineEditDialog extends StatefulHookWidget {
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

  @override
  Widget build(BuildContext context) {
    final domainsProvider = useProvider(pickDomainsProvider);
    final domains = useProvider(pickDomainsProvider.state);
    final locationsProvider = useProvider(pickLocationsProvider);
    final locations = useProvider(pickLocationsProvider.state);
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
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _classificationController,
            onChanged: (value) => setState(() => _handleDisabled(value)),
            decoration: const InputDecoration(labelText: "Classement"),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _commentController,
            onChanged: (value) => setState(() => _handleDisabled(value)),
            decoration: const InputDecoration(labelText: "Commentaire"),
          ),
          const SizedBox(height: 16.0),
          domains.when(
            data: (suggestions) => ItemPicker<Domain>(
              item: _domain,
              suggestions: suggestions,
              fetchItems: (value) => domainsProvider.fetch(value),
              onChanged: (EquatableWithName r) => setState(() {
                _domain = r;
                domainsProvider.clear();
              }),
              itemHintMessage: "Domaine",
              nullItemMessage: "Domaine requis",
            ),
            loading: () => const ProgressWidget(),
            error: (error, _) => ScreenErrorWidget(error: error),
          ),
          SizedBox(height: 16.0),
          locations.when(
            data: (suggestions) => ItemPicker<Location>(
              item: _location,
              suggestions: suggestions,
              fetchItems: (value) => locationsProvider.fetch(value),
              onChanged: (EquatableWithName r) => setState(() {
                _location = r;
                locationsProvider.clear();
              }),
              itemHintMessage: "Appellation",
              nullItemMessage: "Appellation requise",
            ),
            loading: () => const ProgressWidget(),
            error: (error, _) => ScreenErrorWidget(error: error),
          ),
        ],
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
              : () => Navigator.of(context).pop(Wine(
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
