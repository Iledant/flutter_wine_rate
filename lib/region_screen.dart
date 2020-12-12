import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_wine_rate/constant.dart';
import 'package:flutter_wine_rate/redux/regions/regions_actions.dart';
import 'package:flutter_wine_rate/redux/store.dart';
import 'package:flutter_wine_rate/region_edit_dialog.dart';

import 'config.dart';
import 'drawer.dart';
import 'models/region.dart';

class RegionScreen extends StatefulWidget {
  final Config config;

  RegionScreen(this.config, {Key key}) : super(key: key);

  @override
  _RegionScreenState createState() => _RegionScreenState();
}

class PaginatedTable extends StatelessWidget {
  final TableHeaders headers;
  final TableRowText rows;
  final Function(int) editHook;
  final Function(int) deleteHook;

  PaginatedTable(
      {@required this.headers,
      @required this.rows,
      @required this.editHook,
      @required this.deleteHook,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DataColumn> dataColumns =
        headers.columns.map((e) => DataColumn(label: Text(e))).toList();
    if (headers.hasAction) {
      dataColumns.add(DataColumn(label: Text('Actions')));
    }
    final actualLine = rows.actualLine;
    final totalLines = rows.totalLines;
    final lastLine = min(actualLine + 10, totalLines);
    final backButtonDisabled = actualLine == 1;
    final nextButtonDisabled = totalLines == lastLine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DataTable(
            headingRowColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return Colors.deepPurple.shade50;
            }),
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            columns: dataColumns,
            rows: List<DataRow>.generate(
              lastLine - actualLine + 1,
              (i) => DataRow(
                cells: [
                  ...rows.rows(i).map((r) => DataCell(Text(r))).toList(),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          iconSize: 16.0,
                          splashRadius: 16.0,
                          onPressed: () => editHook(i),
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          splashRadius: 16.0,
                          iconSize: 16.0,
                          onPressed: () => deleteHook(i),
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )),
        SizedBox(height: 8.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$actualLine - $lastLine sur $totalLines'),
            SizedBox(width: 16.0),
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: backButtonDisabled ? Colors.grey : Colors.black,
              ),
              splashRadius: 16.0,
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_right,
                color: nextButtonDisabled ? Colors.grey : Colors.black,
              ),
              splashRadius: 16.0,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class _RegionScreenState extends State<RegionScreen> {
  final _controller = TextEditingController();

  void initState() {
    super.initState();
    Redux.store.dispatch((store) => fetchPaginatedRegionsAction(
        store, widget.config, PaginatedParams('', 1, FieldSort.NameSort)));
    _controller.addListener(() {
      Redux.store.dispatch((store) => fetchPaginatedRegionsAction(
          store,
          widget.config,
          PaginatedParams(_controller.text, 1, FieldSort.NameSort)));
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
                      PaginatedParams(_controller.text,
                          paginatedRegions.actualLine, FieldSort.NameSort)),
                ).build(builder);
              },
            ),
          ],
        ),
      ),
    );
  }
}
