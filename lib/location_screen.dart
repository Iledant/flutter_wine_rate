import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_wine_rate/providers/location_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'common_scaffold.dart';
import 'constants.dart';
import 'delete_dialog.dart';
import 'paginated_table.dart';
import 'location_edit_dialog.dart';
import 'models/location.dart';
import 'models/pagination.dart';
import 'repo/location_repo.dart';
import 'screen_widget.dart';

class LocationScreen extends HookWidget {
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  LocationScreen({Key key}) : super(key: key);

  void _addOrModify(DialogMode mode, BuildContext context, Location location,
      PaginatedLocationsProvider provider) async {
    final result = await showEditLocationDialog(context, location, mode);
    if (result == null) return;

    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    if (mode == DialogMode.Edit)
      provider.update(result, params);
    else
      provider.add(result, params);
  }

  void _remove(Location location, BuildContext context, PaginatedParams params,
      PaginatedLocationsProvider provider) async {
    final confirm =
        await showDeleteDialog(context, "l'appellation ", location.name);
    if (!confirm) return;
    provider.remove(location, params);
  }

  Widget _tableWidget(BuildContext context, PaginatedLocations locations,
          PaginatedLocationsProvider provider) =>
      Center(
        child: PaginatedTable(
          color: Colors.deepPurple.shade50,
          rows: locations,
          editHook: (i) => _addOrModify(
              DialogMode.Edit, context, locations.lines[i], provider),
          addHook: () => _addOrModify(DialogMode.Create, context,
              Location(id: 0, name: '', regionId: 0, region: ''), provider),
          deleteHook: (i) => _remove(
            locations.lines[i],
            context,
            PaginatedParams(
              search: _nameController.text,
              firstLine: locations.actualLine,
              sort: FieldSort.Name,
            ),
            provider,
          ),
          moveHook: (i) => provider.fetch(
            PaginatedParams(
              firstLine: i,
              search: _nameController.text,
              sort: FieldSort.Name,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    final provider = useProvider(paginatedLocationsProvider);
    final locations = useProvider(paginatedLocationsProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          Row(
            children: [
              Icon(
                Icons.home_outlined,
                size: titleStyle.fontSize,
                color: titleStyle.color,
              ),
              Text(' Appellations', style: titleStyle),
            ],
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: TextFormField(
                controller: _nameController,
                onChanged: (value) => provider.fetch(
                  PaginatedParams(
                    search: _nameController.text,
                    sort: FieldSort.Name,
                  ),
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Recherche',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          locations.when(
            data: (locations) => _tableWidget(context, locations, provider),
            loading: () => const ProgressWidget(),
            error: (error, __) => ScreenErrorWidget(error: error),
          ),
        ],
      ),
    );
  }
}
