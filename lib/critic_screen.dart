import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_wine_rate/constant.dart';
import 'package:flutter_wine_rate/paginated_table.dart';
import 'package:flutter_wine_rate/redux/critics/critics_actions.dart';
import 'package:flutter_wine_rate/redux/store.dart';
import 'package:flutter_wine_rate/critic_edit_dialog.dart';

import 'config.dart';
import 'drawer.dart';
import 'models/critic.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text('Wine Rate')),
      drawer: AppDrawer(),
      body: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          controller: _scrollController,
          child: Column(
            children: [
              Text('Critiques', style: TextStyle(fontSize: 24.0)),
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
                converter: (store) => store.state.criticsState.isLoading,
                builder: (context, isLoading) {
                  return isLoading
                      ? CircularProgressIndicator(value: null)
                      : SizedBox.shrink();
                },
              ),
              StoreConnector<AppState, bool>(
                distinct: true,
                converter: (store) => store.state.criticsState.isError,
                builder: (context, isError) {
                  return isError
                      ? Text('Erreur de récupération des critiques')
                      : SizedBox.shrink();
                },
              ),
              StoreConnector<AppState, PaginatedCritics>(
                distinct: true,
                converter: (store) => store.state.criticsState.paginatedCritics,
                builder: (builder, paginatedCritics) {
                  return PaginatedTable(
                    headers: TableHeaders(hasAction: true, columns: ['Nom']),
                    rows: paginatedCritics,
                    editHook: (i) => editCritic(
                        DialogMode.Edit, paginatedCritics.critics[i]),
                    deleteHook: (i) => removeCritic(
                      paginatedCritics.critics[i],
                      PaginatedParams(
                        search: _controller.text,
                        firstLine: paginatedCritics.actualLine,
                        sort: FieldSort.NameSort,
                      ),
                    ),
                    moveHook: (i) async {
                      await Redux.store
                          .dispatch((store) => fetchPaginatedCriticsAction(
                                store,
                                widget.config,
                                PaginatedParams(
                                  firstLine: i,
                                  search: _controller.text,
                                  sort: FieldSort.NameSort,
                                ),
                              ));
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
