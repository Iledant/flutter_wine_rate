import 'package:flutter_wine_rate/redux/domains/domains_actions.dart';
import 'package:flutter_wine_rate/redux/domains/domains_state.dart';

domainsReducer(DomainsState prevState, SetDomainsStateAction action) {
  final payload = action.domainsState;
  return prevState.copyWith(
      isError: payload.isError,
      isLoading: payload.isLoading,
      domains: payload.domains,
      paginatedDomains: payload.paginatedDomains);
}
