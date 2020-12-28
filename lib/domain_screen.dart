import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'constant.dart';
import 'paginated_table.dart';
import 'redux/store.dart';
import 'domain_edit_dialog.dart';
import 'common_scaffold.dart';
import 'config.dart';
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
    _controller.addListener(() => fetchElements());
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addOrModify(DialogMode mode, Domain domain) async {
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
    fetchElements();
  }

  void fetchElements() {
    Redux.store.dispatch((store) => fetchPaginatedDomainsAction(
        store,
        widget.config,
        PaginatedParams(search: _controller.text, sort: FieldSort.NameSort)));
  }

  void removeDomain(Domain domain, PaginatedParams params) async {
    await Redux.store.dispatch(
        (store) => removeDomainAction(store, widget.config, domain, params));
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
            Text(' Domaines', style: titleStyle),
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
            converter: (store) => store.state.domains.isLoading,
            builder: (context, isLoading) {
              return isLoading
                  ? CircularProgressIndicator(value: null)
                  : SizedBox.shrink();
            },
          ),
          StoreConnector<AppState, bool>(
            distinct: true,
            converter: (store) => store.state.domains.isError,
            builder: (context, isError) {
              return isError
                  ? Text('Erreur de récupération des domaines')
                  : SizedBox.shrink();
            },
          ),
          StoreConnector<AppState, PaginatedDomains>(
            distinct: true,
            converter: (store) => store.state.domains.paginatedDomains,
            builder: (builder, paginatedDomains) {
              return Center(
                child: PaginatedTable(
                  color: Colors.deepPurple.shade50,
                  hasAction: true,
                  rows: paginatedDomains,
                  editHook: (i) =>
                      addOrModify(DialogMode.Edit, paginatedDomains.domains[i]),
                  addHook: () =>
                      addOrModify(DialogMode.Create, Domain(id: 0, name: '')),
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
