import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers/wine_provider.dart';
import 'repo/wine_repo.dart';
import 'constants.dart';
import 'paginated_table.dart';
import 'delete_dialog.dart';
import 'screen_widget.dart';
import 'wine_edit_dialog.dart';
import 'common_scaffold.dart';
import 'models/wine.dart';
import 'models/pagination.dart';

class WineScreen extends HookWidget {
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();

  void _addOrModify(DialogMode mode, BuildContext context, Wine wine,
      PaginatedWinesProvider provider) async {
    final result = await showEditWineDialog(context, wine, mode);
    if (result == null) return;
    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    if (mode == DialogMode.Edit)
      provider.update(result, params);
    else
      provider.add(result, params);
  }

  void _remove(Wine location, BuildContext context, PaginatedParams params,
      PaginatedWinesProvider provider) async {
    final confirm = await showDeleteDialog(context, location.name);
    if (!confirm) return;
    provider.remove(location, params);
  }

  Widget _tableWidget(BuildContext context, PaginatedWines wines,
          PaginatedWinesProvider provider) =>
      Center(
        child: PaginatedTable(
          color: Colors.deepPurple.shade50,
          rows: wines,
          editHook: (i) =>
              _addOrModify(DialogMode.Edit, context, wines.lines[i], provider),
          addHook: () => _addOrModify(
            DialogMode.Create,
            context,
            Wine(
              id: 0,
              name: '',
              regionId: 0,
              region: '',
              comment: '',
              classification: '',
              locationId: 0,
              location: '',
              domainId: 0,
              domain: '',
            ),
            provider,
          ),
          deleteHook: (i) => _remove(
            wines.lines[i],
            context,
            PaginatedParams(
              search: _nameController.text,
              firstLine: wines.actualLine,
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
    final provider = useProvider(paginatedWinesProvider);
    final wines = useProvider(paginatedWinesProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          Row(
            children: [
              Icon(
                Icons.wine_bar_outlined,
                size: titleStyle.fontSize,
                color: titleStyle.color,
              ),
              Text(' Vins', style: titleStyle),
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
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Recherche',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          wines.when(
            data: (wines) => _tableWidget(context, wines, provider),
            loading: () => const ProgressWidget(),
            error: (error, __) => ScreenErrorWidget(error: error),
          ),
        ],
      ),
    );
  }
}
