import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repo/wine_repo.dart';
import 'bloc/wines.dart';
import 'constants.dart';
import 'paginated_table.dart';
import 'delete_dialog.dart';
import 'wine_edit_dialog.dart';
import 'common_scaffold.dart';
import 'models/wine.dart';
import 'models/pagination.dart';

class WineScreen extends StatelessWidget {
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();

  void _addOrModify(DialogMode mode, BuildContext context, Wine wine) async {
    final result = await showEditWineDialog(context, wine, mode);
    if (result == null) return;
    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    switch (mode) {
      case DialogMode.Edit:
        BlocProvider.of<WinesBloc>(context).add(WineUpdated(result, params));
        break;
      default:
        BlocProvider.of<WinesBloc>(context).add(WineAdded(result, params));
        break;
    }
  }

  void _remove(
      Wine location, BuildContext context, PaginatedParams params) async {
    final confirm =
        await showDeleteDialog(context, "l'appellation ", location.name);
    if (!confirm) return;
    BlocProvider.of<WinesBloc>(context).add(WineDeleted(location, params));
  }

  Widget _emptyWidget(BuildContext context) {
    BlocProvider.of<WinesBloc>(context).add(
      WinesLoaded(
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

  Widget _loadedWidget(BuildContext context, PaginatedWines wines) => Center(
        child: PaginatedTable(
          color: Colors.deepPurple.shade50,
          rows: wines,
          editHook: (i) =>
              _addOrModify(DialogMode.Edit, context, wines.lines[i]),
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
              )),
          deleteHook: (i) => _remove(
            wines.lines[i],
            context,
            PaginatedParams(
              search: _nameController.text,
              firstLine: wines.actualLine,
              sort: FieldSort.Name,
            ),
          ),
          moveHook: (i) => BlocProvider.of<WinesBloc>(context).add(
            WinesLoaded(
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
                Icons.wine_bar_outlined,
                size: titleStyle.fontSize,
                color: titleStyle.color,
              ),
              Text(' Vins', style: titleStyle),
            ],
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: TextFormField(
                controller: _nameController,
                onChanged: (value) => BlocProvider.of<WinesBloc>(context).add(
                  WinesLoaded(
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
          BlocBuilder<WinesBloc, WinesState>(builder: (context, state) {
            if (state is WinesEmpty) return _emptyWidget(context);
            if (state is WinesLoadInProgress) return _progressWidget();
            if (state is WinesLoadFailure) return _errorWidget();
            final locations = (state as WinesLoadSuccess).wines;
            return _loadedWidget(context, locations);
          }),
        ],
      ),
    );
  }
}
