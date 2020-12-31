import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'constant.dart';
import 'paginated_table.dart';
import 'redux/store.dart';
import 'wine_edit_dialog.dart';
import 'common_scaffold.dart';
import 'config.dart';
import 'redux/wine_state.dart';
import 'models/wine.dart';
import 'models/pagination.dart';

class WineScreen extends StatefulWidget {
  final Config config;

  WineScreen(this.config, {Key key}) : super(key: key);

  @override
  _WineScreenState createState() => _WineScreenState();
}

class _WineScreenState extends State<WineScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void initState() {
    super.initState();
    Redux.store.dispatch((store) => fetchPaginatedWinesAction(
        store, widget.config, PaginatedParams(sort: FieldSort.NameSort)));
    _controller.addListener(() => fetchElements());
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addOrModify(DialogMode mode, Wine wine) async {
    final result = await showDialog<Wine>(
        context: context,
        barrierDismissible: false,
        builder: (context) => WineEditDialog(mode, wine, widget.config));
    if (result == null) return;
    switch (mode) {
      case DialogMode.Edit:
        await Redux.store.dispatch(
            (store) => updateWineAction(store, widget.config, result));
        break;
      default:
        await Redux.store
            .dispatch((store) => addWineAction(store, widget.config, result));
    }
    fetchElements();
  }

  void fetchElements() {
    Redux.store.dispatch((store) => fetchPaginatedWinesAction(
        store,
        widget.config,
        PaginatedParams(search: _controller.text, sort: FieldSort.NameSort)));
  }

  void removeWine(Wine wine, PaginatedParams params) async {
    await Redux.store.dispatch(
        (store) => removeWineAction(store, widget.config, wine, params));
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
              Icons.home_outlined,
              size: titleStyle.fontSize,
              color: titleStyle.color,
            ),
            Text(' Winees', style: titleStyle),
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
            converter: (store) => store.state.wines.isLoading,
            builder: (context, isLoading) {
              return isLoading
                  ? CircularProgressIndicator(value: null)
                  : SizedBox.shrink();
            },
          ),
          StoreConnector<AppState, bool>(
            distinct: true,
            converter: (store) => store.state.wines.isError,
            builder: (context, isError) {
              return isError
                  ? Text('Erreur de récupération des winees')
                  : SizedBox.shrink();
            },
          ),
          StoreConnector<AppState, PaginatedWines>(
            distinct: true,
            converter: (store) => store.state.wines.paginatedWines,
            builder: (builder, paginatedWines) {
              return Center(
                child: PaginatedTable(
                  color: Colors.deepPurple.shade50,
                  hasAction: true,
                  rows: paginatedWines,
                  editHook: (i) =>
                      addOrModify(DialogMode.Edit, paginatedWines.wines[i]),
                  addHook: () => addOrModify(
                      DialogMode.Create,
                      Wine(
                          id: 0,
                          name: '',
                          comment: null,
                          classification: null,
                          locationId: 0,
                          location: null,
                          domainId: 0,
                          domain: null)),
                  deleteHook: (i) => removeWine(
                    paginatedWines.wines[i],
                    PaginatedParams(
                      search: _controller.text,
                      firstLine: paginatedWines.actualLine,
                      sort: FieldSort.NameSort,
                    ),
                  ),
                  moveHook: (i) async => {
                    await Redux.store.dispatch(
                      (store) => fetchPaginatedWinesAction(
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
              );
            },
          ),
        ],
      ),
    );
  }
}
