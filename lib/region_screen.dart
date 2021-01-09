import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/regions.dart';
import 'common_scaffold.dart';
import 'constant.dart';
import 'delete_dialog.dart';
import 'paginated_table.dart';
import 'region_edit_dialog.dart';
import 'models/region.dart';
import 'models/pagination.dart';
import 'repo/region_repo.dart';

class RegionScreen extends StatelessWidget {
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  RegionScreen({Key key}) : super(key: key);

  void _addOrModify(
      DialogMode mode, BuildContext context, Region region) async {
    final result = await showEditRegionDialog(context, region, mode);
    if (result == null) return;
    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    switch (mode) {
      case DialogMode.Edit:
        BlocProvider.of<RegionsBloc>(context)
            .add(RegionUpdated(result, params));
        break;
      default:
        BlocProvider.of<RegionsBloc>(context).add(RegionAdded(result, params));
        break;
    }
  }

  void _remove(
      Region region, BuildContext context, PaginatedParams params) async {
    final confirm = await showDeleteDialog(context, 'la région ', region.name);
    if (!confirm) return;
    BlocProvider.of<RegionsBloc>(context).add(RegionDeleted(region, params));
  }

  Widget _emptyWidget(BuildContext context) {
    BlocProvider.of<RegionsBloc>(context).add(
      RegionsLoaded(
        PaginatedParams(
          search: _nameController.text,
          sort: FieldSort.Name,
        ),
      ),
    );
    return SizedBox.shrink();
  }

  Widget _progressWidget() =>
      Center(child: CircularProgressIndicator(value: null));

  Widget _errorWidget() => Center(
        child: Container(
          color: Colors.red,
          padding: EdgeInsets.all(8.0),
          child: Text('Erreur de chargement'),
        ),
      );

  Widget _loadedWidget(BuildContext context, PaginatedRegions regions) =>
      Center(
        child: PaginatedTable(
          color: Colors.deepPurple.shade50,
          hasAction: true,
          rows: regions,
          editHook: (i) =>
              _addOrModify(DialogMode.Edit, context, regions.lines[i]),
          addHook: () =>
              _addOrModify(DialogMode.Create, context, Region(id: 0, name: '')),
          deleteHook: (i) => _remove(
            regions.lines[i],
            context,
            PaginatedParams(
              search: _nameController.text,
              firstLine: regions.actualLine,
              sort: FieldSort.Name,
            ),
          ),
          moveHook: (i) => BlocProvider.of<RegionsBloc>(context).add(
            RegionsLoaded(
              PaginatedParams(
                firstLine: i,
                search: _nameController.text,
                sort: FieldSort.Name,
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
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
                onChanged: (value) => BlocProvider.of<RegionsBloc>(context).add(
                  RegionsLoaded(
                    PaginatedParams(
                      search: _nameController.text,
                      sort: FieldSort.Name,
                    ),
                  ),
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Recherche',
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          BlocBuilder<RegionsBloc, RegionsState>(builder: (context, state) {
            if (state is RegionsEmpty) return _emptyWidget(context);
            if (state is RegionsLoadInProgress) return _progressWidget();
            if (state is RegionsLoadFailure) return _errorWidget();
            final regions = (state as RegionsLoadSuccess).regions;
            return _loadedWidget(context, regions);
          }),
        ],
      ),
    );
  }
}
