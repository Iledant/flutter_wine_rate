import 'package:flutter_wine_rate/models/critic.dart';
import 'package:flutter_wine_rate/models/paginated_params.dart';
import 'package:flutter_wine_rate/redux/critics/critics_state.dart';
import 'package:flutter_wine_rate/redux/store.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';

import '../../config.dart';

@immutable
class SetCriticsStateAction {
  final CriticsState criticsState;

  SetCriticsStateAction(this.criticsState);
}

Future<void> fetchCriticsAction(Store<AppState> store, Config config) async {
  store.dispatch(SetCriticsStateAction(CriticsState(isLoading: true)));

  try {
    final critics = await Critic.getAll(config);
    store.dispatch(SetCriticsStateAction(
        CriticsState(isLoading: false, critics: critics)));
  } catch (error) {
    store.dispatch(SetCriticsStateAction(CriticsState(isLoading: false)));
  }
}

Future<void> fetchPaginatedCriticsAction(
    Store<AppState> store, Config config, PaginatedParams params) async {
  store.dispatch(SetCriticsStateAction(CriticsState(isLoading: true)));
  try {
    final paginatedCritics = await Critic.getPaginated(config, params);
    store.dispatch(SetCriticsStateAction(
        CriticsState(isLoading: false, paginatedCritics: paginatedCritics)));
  } catch (error) {
    store.dispatch(SetCriticsStateAction(CriticsState(isLoading: false)));
  }
}

Future<void> addCriticAction(
    Store<AppState> store, Config config, Critic region) async {
  store.dispatch(SetCriticsStateAction(CriticsState(isLoading: true)));

  try {
    await region.add(config);
    final actualPaginatedCritics = store.state.criticsState.paginatedCritics;
    final newCritics = [...actualPaginatedCritics.critics, region];
    final newPaginatedCritics = PaginatedCritics(
        actualPaginatedCritics.actualLine,
        actualPaginatedCritics.totalLines,
        newCritics);
    store.dispatch(SetCriticsStateAction(
        CriticsState(isLoading: false, paginatedCritics: newPaginatedCritics)));
  } catch (error) {
    store.dispatch(SetCriticsStateAction(CriticsState(isLoading: false)));
  }
}

Future<void> updateCriticAction(
    Store<AppState> store, Config config, Critic region) async {
  store.dispatch(SetCriticsStateAction(CriticsState(isLoading: true)));

  try {
    await region.update(config);
    final actualPaginatedCritics = store.state.criticsState.paginatedCritics;
    final newCritics = actualPaginatedCritics.critics
        .map((e) => e.id == region.id ? region : e)
        .toList();
    final newPaginatedCritics = PaginatedCritics(
        actualPaginatedCritics.actualLine,
        actualPaginatedCritics.totalLines,
        newCritics);
    store.dispatch(SetCriticsStateAction(
        CriticsState(isLoading: false, paginatedCritics: newPaginatedCritics)));
  } catch (error) {
    store.dispatch(SetCriticsStateAction(CriticsState(isLoading: false)));
  }
}

Future<void> removeCriticAction(Store<AppState> store, Config config,
    Critic region, PaginatedParams params) async {
  store.dispatch(SetCriticsStateAction(CriticsState(isLoading: true)));

  try {
    await region.remove(config);
    fetchPaginatedCriticsAction(store, config, params);
  } catch (error) {
    store.dispatch(SetCriticsStateAction(CriticsState(isLoading: false)));
  }
}
