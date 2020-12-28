import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'common_scaffold.dart';
import 'constant.dart';
import 'paginated_table.dart';
import 'redux/store.dart';
import 'redux/regions_state.dart';
import 'region_edit_dialog.dart';
import 'config.dart';
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
  final _scrollController = ScrollController();

  void initState() {
    super.initState();
    Redux.store.dispatch((store) => fetchPaginatedRegionsAction(
        store, widget.config, PaginatedParams(sort: FieldSort.NameSort)));
    _controller.addListener(() => fetchElements());
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addOrModify(DialogMode mode, Region region) async {
    final result = await showDialog<Region>(
        context: context,
        barrierDismissible: false,
        builder: (context) => RegionEditDialog(mode, region));
    if (result == null) return;
    switch (mode) {
      case DialogMode.Edit:
        await Redux.store.dispatch(
            (store) => updateRegionAction(store, widget.config, result));
        break;
      default:
        await Redux.store
            .dispatch((store) => addRegionAction(store, widget.config, result));
    }
    fetchElements();
  }

  void removeRegion(Region region, PaginatedParams params) async {
    await Redux.store.dispatch(
        (store) => removeRegionAction(store, widget.config, region, params));
  }

  void fetchElements() {
    Redux.store.dispatch((store) => fetchPaginatedRegionsAction(
        store,
        widget.config,
        PaginatedParams(search: _controller.text, sort: FieldSort.NameSort)));
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    return CommonScaffold(
      body: ListView(
        padding: EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          Row(children: [
            Icon(
              Icons.map,
              size: titleStyle.fontSize,
              color: titleStyle.color,
            ),
            Text(' Régions', style: titleStyle),
          ]),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Recherche',
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          StoreConnector<AppState, bool>(
            distinct: true,
            converter: (store) => store.state.regions.isLoading,
            builder: (context, isLoading) {
              return isLoading
                  ? CircularProgressIndicator(value: null)
                  : SizedBox.shrink();
            },
          ),
          StoreConnector<AppState, bool>(
            distinct: true,
            converter: (store) => store.state.regions.isError,
            builder: (context, isError) {
              return isError
                  ? Text('Erreur de récupération des régions')
                  : SizedBox.shrink();
            },
          ),
          StoreConnector<AppState, PaginatedRegions>(
            distinct: true,
            converter: (store) => store.state.regions.paginatedRegions,
            builder: (builder, paginatedRegions) {
              return Center(
                child: PaginatedTable(
                  color: Colors.deepPurple.shade50,
                  hasAction: true,
                  rows: paginatedRegions,
                  editHook: (i) =>
                      addOrModify(DialogMode.Edit, paginatedRegions.regions[i]),
                  addHook: () =>
                      addOrModify(DialogMode.Create, Region(id: 0, name: '')),
                  deleteHook: (i) => removeRegion(
                    paginatedRegions.regions[i],
                    PaginatedParams(
                      search: _controller.text,
                      firstLine: paginatedRegions.actualLine,
                      sort: FieldSort.NameSort,
                    ),
                  ),
                  moveHook: (i) async => {
                    await Redux.store.dispatch(
                      (store) => fetchPaginatedRegionsAction(
                        store,
                        widget.config,
                        PaginatedParams(
                            firstLine: i,
                            search: _controller.text,
                            sort: FieldSort.NameSort),
                      ),
                    )
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
