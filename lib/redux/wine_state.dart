import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

import '../models/wine.dart';
import '../models/pagination.dart';
import '../config.dart';
import 'store.dart';

@immutable
class WinesState {
  final bool isError;
  final bool isLoading;
  final List<Wine> wines;
  final PaginatedWines paginatedWines;

  WinesState({this.isError, this.isLoading, this.wines, this.paginatedWines});

  factory WinesState.initial() => WinesState(
      isLoading: false,
      isError: false,
      wines: const [],
      paginatedWines: PaginatedWines(1, 0, []));

  WinesState copyWith(
      {@required bool isError,
      @required bool isLoading,
      @required List<Wine> wines,
      @required PaginatedWines paginatedWines}) {
    return WinesState(
        isError: isError ?? this.isError,
        isLoading: isLoading ?? this.isLoading,
        wines: wines ?? this.wines,
        paginatedWines: paginatedWines ?? this.paginatedWines);
  }
}

winesReducer(WinesState prevState, SetWinesStateAction action) {
  final payload = action.winesState;
  return prevState.copyWith(
      isError: payload.isError,
      isLoading: payload.isLoading,
      wines: payload.wines,
      paginatedWines: payload.paginatedWines);
}

@immutable
class SetWinesStateAction {
  final WinesState winesState;

  SetWinesStateAction(this.winesState);
}

Future<void> fetchPaginatedWinesAction(
    Store<AppState> store, Config config, PaginatedParams params) async {
  store.dispatch(SetWinesStateAction(WinesState(isLoading: true)));
  try {
    final paginatedWines = await Wine.getPaginated(config, params);
    store.dispatch(SetWinesStateAction(
        WinesState(isLoading: false, paginatedWines: paginatedWines)));
  } catch (error) {
    store.dispatch(SetWinesStateAction(WinesState(isLoading: false)));
  }
}

Future<void> addWineAction(
    Store<AppState> store, Config config, Wine wine) async {
  store.dispatch(SetWinesStateAction(WinesState(isLoading: true)));

  try {
    await wine.add(config);
    final actualPaginatedWines = store.state.wines.paginatedWines;
    final newWines = [...actualPaginatedWines.wines, wine];
    final newPaginatedWines = PaginatedWines(actualPaginatedWines.actualLine,
        actualPaginatedWines.totalLines, newWines);
    store.dispatch(SetWinesStateAction(
        WinesState(isLoading: false, paginatedWines: newPaginatedWines)));
  } catch (error) {
    store.dispatch(SetWinesStateAction(WinesState(isLoading: false)));
  }
}

Future<void> updateWineAction(
    Store<AppState> store, Config config, Wine wine) async {
  store.dispatch(SetWinesStateAction(WinesState(isLoading: true)));

  try {
    await wine.update(config);
    final actualPaginatedWines = store.state.wines.paginatedWines;
    final newWines = actualPaginatedWines.wines
        .map((e) => e.id == wine.id ? wine : e)
        .toList();
    final newPaginatedWines = PaginatedWines(actualPaginatedWines.actualLine,
        actualPaginatedWines.totalLines, newWines);
    store.dispatch(SetWinesStateAction(
        WinesState(isLoading: false, paginatedWines: newPaginatedWines)));
  } catch (error) {
    store.dispatch(SetWinesStateAction(WinesState(isLoading: false)));
  }
}

Future<void> removeWineAction(Store<AppState> store, Config config, Wine wine,
    PaginatedParams params) async {
  store.dispatch(SetWinesStateAction(WinesState(isLoading: true)));

  try {
    await wine.remove(config);
    fetchPaginatedWinesAction(store, config, params);
  } catch (error) {
    store.dispatch(SetWinesStateAction(WinesState(isLoading: false)));
  }
}
