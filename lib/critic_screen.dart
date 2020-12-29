import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_wine_rate/redux/critics_state.dart';

import 'common_scaffold.dart';
import 'constant.dart';
import 'paginated_table.dart';
import 'redux/store.dart';
import 'critic_edit_dialog.dart';
import 'config.dart';
import 'models/critic.dart';
import 'models/pagination.dart';

class CriticScreen extends StatefulWidget {
  final Config config;

  CriticScreen(this.config, {Key key}) : super(key: key);

  @override
  _CriticScreenState createState() => _CriticScreenState();
}

class _CriticScreenState extends State<CriticScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void initState() {
    super.initState();
    Redux.store.dispatch((store) => fetchPaginatedCriticsAction(
        store, widget.config, PaginatedParams(sort: FieldSort.NameSort)));
    _controller.addListener(() {
      Redux.store.dispatch((store) => fetchPaginatedCriticsAction(
          store,
          widget.config,
          PaginatedParams(search: _controller.text, sort: FieldSort.NameSort)));
    });
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void editCritic(DialogMode mode, Critic critic) async {
    final result = await showDialog<Critic>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CriticEditDialog(mode, critic),
    );
    if (result == null) return;
    switch (mode) {
      case DialogMode.Edit:
        await Redux.store.dispatch(
            (store) => updateCriticAction(store, widget.config, result));
        break;
      default:
        await Redux.store
            .dispatch((store) => addCriticAction(store, widget.config, result));
    }
  }

  void removeCritic(Critic critic, PaginatedParams params) async {
    await Redux.store.dispatch(
        (store) => removeCriticAction(store, widget.config, critic, params));
  }

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
                Icons.account_circle,
                size: titleStyle.fontSize,
                color: titleStyle.color,
              ),
              Text(' Critiques', style: titleStyle),
            ],
          ),
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
            converter: (store) => store.state.critics.isLoading,
            builder: (context, isLoading) {
              return isLoading
                  ? CircularProgressIndicator(value: null)
                  : SizedBox.shrink();
            },
          ),
          StoreConnector<AppState, bool>(
            distinct: true,
            converter: (store) => store.state.critics.isError,
            builder: (context, isError) {
              return isError
                  ? Text('Erreur de récupération des critiques')
                  : SizedBox.shrink();
            },
          ),
          StoreConnector<AppState, PaginatedCritics>(
            distinct: true,
            converter: (store) => store.state.critics.paginatedCritics,
            builder: (builder, paginatedCritics) {
              return Center(
                child: PaginatedTable(
                  color: Colors.deepPurple.shade50,
                  hasAction: true,
                  rows: paginatedCritics,
                  editHook: (i) =>
                      editCritic(DialogMode.Edit, paginatedCritics.critics[i]),
                  deleteHook: (i) => removeCritic(
                    paginatedCritics.critics[i],
                    PaginatedParams(
                      search: _controller.text,
                      firstLine: paginatedCritics.actualLine,
                      sort: FieldSort.NameSort,
                    ),
                  ),
                  moveHook: (i) async {
                    await Redux.store.dispatch(
                      (store) => fetchPaginatedCriticsAction(
                        store,
                        widget.config,
                        PaginatedParams(
                          firstLine: i,
                          search: _controller.text,
                          sort: FieldSort.NameSort,
                        ),
                      ),
                    );
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
