import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_wine_rate/constant.dart';
import 'package:flutter_wine_rate/paginated_table.dart';
import 'package:flutter_wine_rate/redux/store.dart';
import 'package:flutter_wine_rate/domain_edit_dialog.dart';

import 'config.dart';
import 'drawer.dart';
import 'redux/domains_state.dart';
import 'models/domain.dart';
import 'models/pagination.dart';

class DomainScreen extends StatefulWidget {
  final Config config;

  DomainScreen(this.config, {Key key}) : super(key: key);

  @override
  _DomainScreenState createState() => _DomainScreenState();
}

class _DomainScreenState extends State<DomainScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void initState() {
    super.initState();
    Redux.store.dispatch((store) => fetchPaginatedDomainsAction(
        store, widget.config, PaginatedParams(sort: FieldSort.NameSort)));
    _controller.addListener(() {
      Redux.store.dispatch((store) => fetchPaginatedDomainsAction(
          store,
          widget.config,
          PaginatedParams(search: _controller.text, sort: FieldSort.NameSort)));
    });
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void editDomain(DialogMode mode, Domain domain) async {
    final result = await showDialog<Domain>(
        context: context,
        barrierDismissible: false,
        builder: (context) => DomainEditDialog(mode, domain));
    if (result == null) return;
    switch (mode) {
      case DialogMode.Edit:
        await Redux.store.dispatch(
            (store) => updateDomainAction(store, widget.config, result));
        break;
      default:
        await Redux.store
            .dispatch((store) => addDomainAction(store, widget.config, result));
    }
  }

  void removeDomain(Domain domain, PaginatedParams params) async {
    await Redux.store.dispatch(
        (store) => removeDomainAction(store, widget.config, domain, params));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wine Rate')),
      drawer: AppDrawer(),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          Text(' Domaines', style: TextStyle(fontSize: 24.0)),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: 'Recherche',
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          StoreConnector<AppState, bool>(
            distinct: true,
            converter: (store) => store.state.domainsState.isLoading,
            builder: (context, isLoading) {
              return isLoading
                  ? CircularProgressIndicator(value: null)
                  : SizedBox.shrink();
            },
          ),
          StoreConnector<AppState, bool>(
            distinct: true,
            converter: (store) => store.state.domainsState.isError,
            builder: (context, isError) {
              return isError
                  ? Text('Erreur de récupération des domaines')
                  : SizedBox.shrink();
            },
          ),
          StoreConnector<AppState, PaginatedDomains>(
            distinct: true,
            converter: (store) => store.state.domainsState.paginatedDomains,
            builder: (builder, paginatedDomains) {
              return Center(
                child: PaginatedTable(
                  headers: TableHeaders(hasAction: true, columns: ['Nom']),
                  rows: paginatedDomains,
                  editHook: (i) =>
                      editDomain(DialogMode.Edit, paginatedDomains.domains[i]),
                  deleteHook: (i) => removeDomain(
                    paginatedDomains.domains[i],
                    PaginatedParams(
                      search: _controller.text,
                      firstLine: paginatedDomains.actualLine,
                      sort: FieldSort.NameSort,
                    ),
                  ),
                  moveHook: (i) async => {
                    await Redux.store.dispatch(
                      (store) => fetchPaginatedDomainsAction(
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
