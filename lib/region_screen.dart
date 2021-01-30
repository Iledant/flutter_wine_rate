import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_wine_rate/providers/region_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'common_scaffold.dart';
import 'constants.dart';
import 'delete_dialog.dart';
import 'paginated_table.dart';
import 'region_edit_dialog.dart';
import 'models/region.dart';
import 'models/pagination.dart';
import 'repo/region_repo.dart';
import 'screen_widget.dart';

class RegionScreen extends HookWidget {
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();

  RegionScreen({Key key}) : super(key: key);

  void _addOrModify(DialogMode mode, BuildContext context, Region region,
      PaginatedRegionsProvider provider) async {
    final result = await showEditRegionDialog(context, region, mode);
    if (result == null) return;
    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    switch (mode) {
      case DialogMode.Edit:
        provider.add(result, params);
        break;
      default:
        provider.update(result, params);
        break;
    }
  }

  void _remove(Region region, BuildContext context, PaginatedParams params,
      PaginatedRegionsProvider provider) async {
    final confirm = await showDeleteDialog(context, 'la région ', region.name);
    if (!confirm) return;
    provider.remove(region, params);
  }

  Widget _tableWidget(BuildContext context, PaginatedRegions regions,
          PaginatedRegionsProvider provider) =>
      Center(
        child: PaginatedTable(
          color: Colors.deepPurple.shade50,
          rows: regions,
          editHook: (i) => _addOrModify(
              DialogMode.Edit, context, regions.lines[i], provider),
          addHook: () => _addOrModify(
              DialogMode.Create, context, Region(id: 0, name: ''), provider),
          deleteHook: (i) => _remove(
              regions.lines[i],
              context,
              PaginatedParams(
                search: _nameController.text,
                firstLine: regions.actualLine,
                sort: FieldSort.Name,
              ),
              provider),
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
    final provider = useProvider(paginatedRegionsProvider);
    final regions = useProvider(paginatedRegionsProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          Row(
            children: [
              Icon(
                Icons.map,
                size: titleStyle.fontSize,
                color: titleStyle.color,
              ),
              Text(' Régions', style: titleStyle),
            ],
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: TextFormField(
                controller: _nameController,
                onChanged: (value) => provider.fetch(PaginatedParams(
                  search: _nameController.text,
                  sort: FieldSort.Name,
                )),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Recherche',
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          regions.when(
              loading: () => ProgressWidget(),
              error: (error, _) => ScreenErrorWidget(error: error),
              data: (regions) => _tableWidget(context, regions, provider)),
        ],
      ),
    );
  }
}
