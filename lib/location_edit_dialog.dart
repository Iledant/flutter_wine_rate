import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_wine_rate/providers/region_provider.dart';
import 'package:flutter_wine_rate/screen_widget.dart';
import 'package:hooks_riverpod/all.dart';
import 'constants.dart';
import 'models/pagination.dart';
import 'models/location.dart';
import 'models/region.dart';

class LocationEditDialog extends StatefulHookWidget {
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
    final regions = useProvider(pickRegionsProvider.state);
    final provider = useProvider(pickRegionsProvider);
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
              autofocus: true,
              onChanged: (value) => setState(() => _handleDisabled(value)),
              autovalidateMode: AutovalidateMode.always,
              validator: (String value) =>
                  value.isEmpty ? 'Le nom ne peut être vide' : null,
              decoration:
                  const InputDecoration(labelText: "Nom de l'appellation"),
            ),
          ),
          const SizedBox(height: 16.0),
          regions.when(
            data: (suggestions) => ItemPicker<Region>(
              item: _region,
              suggestions: suggestions,
              fetchItems: (value) => provider.fetch(value),
              onChanged: (EquatableWithName r) => setState(() {
                _region = r;
                provider.clear();
              }),
              itemHintMessage: "Région de l'appellation",
              nullItemMessage: "Région requise",
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
              : () => Navigator.of(context).pop(Location(
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
