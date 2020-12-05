import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_wine_rate/redux/regions/regions_actions.dart';
import 'package:flutter_wine_rate/redux/store.dart';

import 'config.dart';
import 'drawer.dart';
import 'models/region.dart';

class RegionScreen extends StatefulWidget {
  final Config config;

  RegionScreen(this.config, {Key key}) : super(key: key);

  @override
  _RegionScreenState createState() => _RegionScreenState();
}

class _RegionScreenState extends State<RegionScreen> {
  final _controller = TextEditingController();
  String _searchText = '';

  void initState() {
    super.initState();
    Redux.store.dispatch((store) => fetchRegionsAction(store, widget.config));
    _controller.addListener(() {
      setState(() {
        _searchText = _controller.text.toLowerCase();
      });
    });
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addRegion(Region region) async {
    await Redux.store
        .dispatch((store) => addRegionAction(store, widget.config, region));
  }

  void removeRegion(Region region) async {
    await Redux.store
        .dispatch((store) => removeRegionAction(store, widget.config, region));
  }

  Widget regionTable(List<Region> regions) {
    final lines = regions
        .where((r) => r.name.toLowerCase().contains(_searchText))
        .toList();

    return Card(
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Colors.deepPurple.shade50;
          }),
          headingTextStyle:
              TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          columns: [
            DataColumn(label: Text('Nom')),
            DataColumn(label: Text('Action'))
          ],
          rows: List<DataRow>.generate(
            lines.length,
            (i) => DataRow(
              cells: [
                DataCell(Text(lines[i].name)),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                          iconSize: 16.0,
                          splashRadius: 16.0,
                          onPressed: () =>
                              addRegion(Region(0, 'Nouvelle région')),
                          icon: Icon(Icons.edit)),
                      IconButton(
                          splashRadius: 16.0,
                          iconSize: 16.0,
                          onPressed: () => removeRegion(lines[i]),
                          icon: Icon(Icons.delete)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        elevation: 3.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Wine Rate'),
        ),
        drawer: AppDrawer(),
        body: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(' Régions', style: TextStyle(fontSize: 24.0)),
                Center(
                    child: Container(
                        alignment: Alignment.center,
                        width: min(max(300, screenWidth * 0.5), screenWidth),
                        child: TextFormField(
                          controller: _controller,
                          decoration: InputDecoration(
                              icon: Icon(Icons.search), hintText: 'Recherche'),
                        ))),
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        StoreConnector<AppState, bool>(
                            distinct: true,
                            converter: (store) =>
                                store.state.regionsState.isLoading,
                            builder: (context, isLoading) {
                              return isLoading
                                  ? Text('Chargement')
                                  : SizedBox.shrink();
                            }),
                        StoreConnector<AppState, bool>(
                          distinct: true,
                          converter: (store) =>
                              store.state.regionsState.isError,
                          builder: (context, isError) {
                            return isError
                                ? Text('Erreur de récupération des régions')
                                : SizedBox.shrink();
                          },
                        ),
                        StoreConnector<AppState, List<Region>>(
                          distinct: true,
                          converter: (store) =>
                              store.state.regionsState.regions,
                          builder: (context, regions) {
                            return regionTable(regions);
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )));
  }
}
