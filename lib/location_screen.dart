import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_wine_rate/constant.dart';
import 'package:flutter_wine_rate/paginated_table.dart';
import 'package:flutter_wine_rate/redux/store.dart';
import 'package:flutter_wine_rate/location_edit_dialog.dart';

import 'config.dart';
import 'drawer.dart';
import 'redux/locations_state.dart';
import 'models/location.dart';
import 'models/pagination.dart';

class LocationScreen extends StatefulWidget {
  final Config config;

  LocationScreen({@required this.config, Key key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void initState() {
    super.initState();
    Redux.store.dispatch((store) => fetchPaginatedLocationsAction(
        store, widget.config, PaginatedParams(sort: FieldSort.NameSort)));
    _controller.addListener(() {
      Redux.store.dispatch((store) => fetchPaginatedLocationsAction(
          store,
          widget.config,
          PaginatedParams(search: _controller.text, sort: FieldSort.NameSort)));
    });
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void editLocation(DialogMode mode, Location location) async {
    final config = widget.config;
    final result = await showDialog<Location>(
        context: context,
        barrierDismissible: false,
        builder: (_) => LocationEditDialog(mode, location, config));
    if (result == null) return;

    if (mode == DialogMode.Edit) {
      await Redux.store
          .dispatch((store) => updateLocationAction(store, config, result));
    } else {
      await Redux.store
          .dispatch((store) => addLocationAction(store, config, result));
    }
  }

  void removeLocation(Location location, PaginatedParams params) async {
    await Redux.store.dispatch((store) =>
        removeLocationAction(store, widget.config, location, params));
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    return Scaffold(
      appBar: AppBar(title: Text('Wine Rate')),
      drawer: AppDrawer(),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          Row(children: [
            Icon(
              Icons.location_on,
              size: titleStyle.fontSize,
              color: titleStyle.color,
            ),
            Text(' Appellations', style: titleStyle),
          ]),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                    icon: Icon(Icons.search), hintText: 'Recherche'),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          StoreConnector<AppState, bool>(
            distinct: true,
            converter: (store) => store.state.locations.isLoading,
            builder: (_, isLoading) => isLoading
                ? CircularProgressIndicator(value: null)
                : SizedBox.shrink(),
          ),
          StoreConnector<AppState, bool>(
            distinct: true,
            converter: (store) => store.state.locations.isError,
            builder: (_, isError) => isError
                ? Text('Erreur de récupération des appellations')
                : SizedBox.shrink(),
          ),
          StoreConnector<AppState, PaginatedLocations>(
            distinct: true,
            converter: (store) => store.state.locations.paginatedLocations,
            builder: (builder, paginatedLocations) {
              return Center(
                child: Card(
                  color: Colors.deepPurple.shade50,
                  child: PaginatedTable(
                    hasAction: true,
                    rows: paginatedLocations,
                    editHook: (i) => editLocation(
                        DialogMode.Edit, paginatedLocations.locations[i]),
                    addHook: () => editLocation(
                        DialogMode.Create, Location(id: 0, name: '')),
                    deleteHook: (i) => removeLocation(
                      paginatedLocations.locations[i],
                      PaginatedParams(
                        search: _controller.text,
                        firstLine: paginatedLocations.actualLine,
                        sort: FieldSort.NameSort,
                      ),
                    ),
                    moveHook: (i) async => {
                      await Redux.store.dispatch(
                        (store) => fetchPaginatedLocationsAction(
                          store,
                          widget.config,
                          PaginatedParams(
                            firstLine: i,
                            search: _controller.text,
                            sort: FieldSort.NameSort,
                          ),
                        ),
                      )
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
