import 'package:flutter/foundation.dart';
import 'package:redux/redux.dart';

import '../models/critic.dart';
import '../models/pagination.dart';
import '../config.dart';
import 'store.dart';

@immutable
class CriticsState {
  final bool isError;
  final bool isLoading;
  final List<Critic> critics;
  final PaginatedCritics paginatedCritics;

  CriticsState(
      {this.isError, this.isLoading, this.critics, this.paginatedCritics});

  factory CriticsState.initial() => CriticsState(
      isLoading: false,
      isError: false,
      critics: const [],
      paginatedCritics: PaginatedCritics(1, 0, []));

  CriticsState copyWith(
      {@required bool isError,
      @required bool isLoading,
      @required List<Critic> critics,
      @required PaginatedCritics paginatedCritics}) {
    return CriticsState(
        isError: isError ?? this.isError,
        isLoading: isLoading ?? this.isLoading,
        critics: critics ?? this.critics,
        paginatedCritics: paginatedCritics ?? this.paginatedCritics);
  }
}

criticsReducer(CriticsState prevState, SetCriticsStateAction action) {
  final payload = action.criticsState;
  return prevState.copyWith(
      isError: payload.isError,
      isLoading: payload.isLoading,
      critics: payload.critics,
      paginatedCritics: payload.paginatedCritics);
}

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
    final actualPaginatedCritics = store.state.critics.paginatedCritics;
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
    final actualPaginatedCritics = store.state.critics.paginatedCritics;
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
