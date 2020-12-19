import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

import '../config.dart';
import 'store.dart';
import '../models/pagination.dart';
import '../models/domain.dart';

@immutable
class DomainsState {
  final bool isError;
  final bool isLoading;
  final List<Domain> domains;
  final PaginatedDomains paginatedDomains;

  DomainsState(
      {this.isError, this.isLoading, this.domains, this.paginatedDomains});

  factory DomainsState.initial() => DomainsState(
      isLoading: false,
      isError: false,
      domains: const [],
      paginatedDomains: PaginatedDomains(1, 0, []));

  DomainsState copyWith(
      {@required bool isError,
      @required bool isLoading,
      @required List<Domain> domains,
      @required PaginatedDomains paginatedDomains}) {
    return DomainsState(
        isError: isError ?? this.isError,
        isLoading: isLoading ?? this.isLoading,
        domains: domains ?? this.domains,
        paginatedDomains: paginatedDomains ?? this.paginatedDomains);
  }
}

@immutable
class SetDomainsStateAction {
  final DomainsState domainsState;

  SetDomainsStateAction(this.domainsState);
}

Future<void> fetchDomainsAction(Store<AppState> store, Config config) async {
  store.dispatch(SetDomainsStateAction(DomainsState(isLoading: true)));

  try {
    final domains = await Domain.getAll(config);
    store.dispatch(SetDomainsStateAction(
        DomainsState(isLoading: false, domains: domains)));
  } catch (error) {
    store.dispatch(SetDomainsStateAction(DomainsState(isLoading: false)));
  }
}

Future<void> fetchPaginatedDomainsAction(
    Store<AppState> store, Config config, PaginatedParams params) async {
  store.dispatch(SetDomainsStateAction(DomainsState(isLoading: true)));
  try {
    final paginatedDomains = await Domain.getPaginated(config, params);
    store.dispatch(SetDomainsStateAction(
        DomainsState(isLoading: false, paginatedDomains: paginatedDomains)));
  } catch (error) {
    store.dispatch(SetDomainsStateAction(DomainsState(isLoading: false)));
  }
}

Future<void> addDomainAction(
    Store<AppState> store, Config config, Domain domain) async {
  store.dispatch(SetDomainsStateAction(DomainsState(isLoading: true)));

  try {
    await domain.add(config);
    final actualPaginatedDomains = store.state.domains.paginatedDomains;
    final newDomains = [...actualPaginatedDomains.domains, domain];
    final newPaginatedDomains = PaginatedDomains(
        actualPaginatedDomains.actualLine,
        actualPaginatedDomains.totalLines,
        newDomains);
    store.dispatch(SetDomainsStateAction(
        DomainsState(isLoading: false, paginatedDomains: newPaginatedDomains)));
  } catch (error) {
    store.dispatch(SetDomainsStateAction(DomainsState(isLoading: false)));
  }
}

Future<void> updateDomainAction(
    Store<AppState> store, Config config, Domain domain) async {
  store.dispatch(SetDomainsStateAction(DomainsState(isLoading: true)));

  try {
    await domain.update(config);
    final actualPaginatedDomains = store.state.domains.paginatedDomains;
    final newDomains = actualPaginatedDomains.domains
        .map((e) => e.id == domain.id ? domain : e)
        .toList();
    final newPaginatedDomains = PaginatedDomains(
        actualPaginatedDomains.actualLine,
        actualPaginatedDomains.totalLines,
        newDomains);
    store.dispatch(SetDomainsStateAction(
        DomainsState(isLoading: false, paginatedDomains: newPaginatedDomains)));
  } catch (error) {
    store.dispatch(SetDomainsStateAction(DomainsState(isLoading: false)));
  }
}

Future<void> removeDomainAction(Store<AppState> store, Config config,
    Domain domain, PaginatedParams params) async {
  store.dispatch(SetDomainsStateAction(DomainsState(isLoading: true)));

  try {
    await domain.remove(config);
    fetchPaginatedDomainsAction(store, config, params);
  } catch (error) {
    store.dispatch(SetDomainsStateAction(DomainsState(isLoading: false)));
  }
}

domainsReducer(DomainsState prevState, SetDomainsStateAction action) {
  final payload = action.domainsState;
  return prevState.copyWith(
      isError: payload.isError,
      isLoading: payload.isLoading,
      domains: payload.domains,
      paginatedDomains: payload.paginatedDomains);
}
