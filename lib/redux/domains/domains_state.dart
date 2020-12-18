import 'package:meta/meta.dart';
import 'package:flutter_wine_rate/models/domain.dart';

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
