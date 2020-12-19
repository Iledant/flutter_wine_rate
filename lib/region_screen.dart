import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_wine_rate/constant.dart';
import 'package:flutter_wine_rate/paginated_table.dart';
import 'package:flutter_wine_rate/redux/regions/regions_actions.dart';
import 'package:flutter_wine_rate/redux/store.dart';
import 'package:flutter_wine_rate/region_edit_dialog.dart';

import 'config.dart';
import 'drawer.dart';
import 'models/pagination.dart';
import 'models/region.dart';

class RegionScreen extends StatefulWidget {
  final Config config;

  RegionScreen(this.config, {Key key}) : super(key: key);

  @override
  _RegionScreenState createState() => _RegionScreenState();
}

class _RegionScreenState extends State<RegionScreen> {
  final _controller = TextEditingController();

  void initState() {
    super.initState();
    Redux.store.dispatch((store) => fetchPaginatedRegionsAction(
        store, widget.config, PaginatedParams(sort: FieldSort.NameSort)));
    _controller.addListener(() {
      Redux.store.dispatch((store) => fetchPaginatedRegionsAction(
          store,
          widget.config,
          PaginatedParams(search: _controller.text, sort: FieldSort.NameSort)));
    });
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void editRegion(DialogMode mode, Region region) async {
    final result = await showDialog<Region>(
        context: context,
        barrierDismissible: false,
        builder: (context) => RegionEditDialog(mode, region));
    if (result == null) {
      return;
    }
    switch (mode) {
      case DialogMode.Edit:
        await Redux.store.dispatch(
            (store) => updateRegionAction(store, widget.config, result));
        break;
      default:
        await Redux.store
            .dispatch((store) => addRegionAction(store, widget.config, result));
    }
  }

  void removeRegion(Region region, PaginatedParams params) async {
    await Redux.store.dispatch(
        (store) => removeRegionAction(store, widget.config, region, params));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text('Wine Rate')),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Text(' Régions', style: TextStyle(fontSize: 24.0)),
            Container(
              alignment: Alignment.center,
              width: min(max(300, screenWidth * 0.5), screenWidth),
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: 'Recherche',
                ),
              ),
            ),
            SizedBox(height: 10.0),
            StoreConnector<AppState, bool>(
              distinct: true,
              converter: (store) => store.state.regionsState.isLoading,
              builder: (context, isLoading) {
                return isLoading
                    ? CircularProgressIndicator(value: null)
                    : SizedBox.shrink();
              },
            ),
            StoreConnector<AppState, bool>(
              distinct: true,
              converter: (store) => store.state.regionsState.isError,
              builder: (context, isError) {
                return isError
                    ? Text('Erreur de récupération des régions')
                    : SizedBox.shrink();
              },
            ),
            StoreConnector<AppState, PaginatedRegions>(
              distinct: true,
              converter: (store) => store.state.regionsState.paginatedRegions,
              builder: (builder, paginatedRegions) {
                return PaginatedTable(
                  headers: TableHeaders(hasAction: true, columns: ['Nom']),
                  rows: paginatedRegions,
                  editHook: (i) =>
                      editRegion(DialogMode.Edit, paginatedRegions.regions[i]),
                  deleteHook: (i) => removeRegion(
                    paginatedRegions.regions[i],
                    PaginatedParams(
                        search: _controller.text,
                        firstLine: paginatedRegions.actualLine,
                        sort: FieldSort.NameSort),
                  ),
                  moveHook: (i) async => {
                    await Redux.store.dispatch((store) =>
                        fetchPaginatedRegionsAction(
                            store,
                            widget.config,
                            PaginatedParams(
                                firstLine: i,
                                search: _controller.text,
                                sort: FieldSort.NameSort)))
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
