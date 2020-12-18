import 'package:flutter_wine_rate/models/domain.dart';
import 'package:flutter_wine_rate/redux/store.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:flutter_wine_rate/redux/domains/domains_state.dart';

import '../../config.dart';
import '../../paginated_table.dart';

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
    final actualPaginatedDomains = store.state.domainsState.paginatedDomains;
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
    final actualPaginatedDomains = store.state.domainsState.paginatedDomains;
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
