import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/locations.dart';
import 'common_scaffold.dart';
import 'constant.dart';
import 'delete_dialog.dart';
import 'paginated_table.dart';
import 'location_edit_dialog.dart';
import 'models/location.dart';
import 'models/pagination.dart';
import 'repo/location_repo.dart';

class LocationScreen extends StatelessWidget {
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  LocationScreen({Key key}) : super(key: key);

  void _addOrModify(
      DialogMode mode, BuildContext context, Location location) async {
    final result = await showEditLocationDialog(context, location, mode);
    if (result == null) return;
    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    switch (mode) {
      case DialogMode.Edit:
        BlocProvider.of<LocationsBloc>(context)
            .add(LocationUpdated(result, params));
        break;
      default:
        BlocProvider.of<LocationsBloc>(context)
            .add(LocationAdded(result, params));
        break;
    }
  }

  void _remove(
      Location location, BuildContext context, PaginatedParams params) async {
    final confirm =
        await showDeleteDialog(context, "l'appellation ", location.name);
    if (!confirm) return;
    BlocProvider.of<LocationsBloc>(context)
        .add(LocationDeleted(location, params));
  }

  Widget _emptyWidget(BuildContext context) {
    BlocProvider.of<LocationsBloc>(context).add(
      LocationsLoaded(
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

  Widget _loadedWidget(BuildContext context, PaginatedLocations locations) =>
      Center(
        child: PaginatedTable(
          color: Colors.deepPurple.shade50,
          hasAction: true,
          rows: locations,
          editHook: (i) =>
              _addOrModify(DialogMode.Edit, context, locations.lines[i]),
          addHook: () => _addOrModify(DialogMode.Create, context,
              Location(id: 0, name: '', regionId: 0, region: '')),
          deleteHook: (i) => _remove(
            locations.lines[i],
            context,
            PaginatedParams(
              search: _nameController.text,
              firstLine: locations.actualLine,
              sort: FieldSort.Name,
            ),
          ),
          moveHook: (i) => BlocProvider.of<LocationsBloc>(context).add(
            LocationsLoaded(
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
                Icons.home_outlined,
                size: titleStyle.fontSize,
                color: titleStyle.color,
              ),
              Text(' Appellations', style: titleStyle),
            ],
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: TextFormField(
                controller: _nameController,
                onChanged: (value) =>
                    BlocProvider.of<LocationsBloc>(context).add(
                  LocationsLoaded(
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
          BlocBuilder<LocationsBloc, LocationsState>(builder: (context, state) {
            if (state is LocationsEmpty) return _emptyWidget(context);
            if (state is LocationsLoadInProgress) return _progressWidget();
            if (state is LocationsLoadFailure) return _errorWidget();
            final locations = (state as LocationsLoadSuccess).locations;
            return _loadedWidget(context, locations);
          }),
        ],
      ),
    );
  }
}
