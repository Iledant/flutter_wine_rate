import 'package:equatable/equatable.dart';
import '../models/pagination.dart';
import '../models/domain.dart';

abstract class DomainsEvent extends Equatable {
  const DomainsEvent();

  @override
  List<Object> get props => [];
}

class DomainsLoaded extends DomainsEvent {
  final PaginatedParams params;

  const DomainsLoaded(this.params);

  @override
  List<Object> get props => [params];

  @override
  String toString() => 'DomainsLoaded { params: $params}';
}

class DomainAdded extends DomainsEvent {
  final Domain domain;
  final PaginatedParams params;

  const DomainAdded(this.domain, this.params);

  @override
  List<Object> get props => [domain, params];

  @override
  String toString() => 'DomainUpdated { domain: $domain params: $params}';
}

class DomainUpdated extends DomainsEvent {
  final Domain domain;
  final PaginatedParams params;

  const DomainUpdated(this.domain, this.params);

  @override
  List<Object> get props => [domain, params];

  @override
  String toString() => 'DomainUpdated { domain: $domain params: $params}';
}

class DomainDeleted extends DomainsEvent {
  final Domain domain;
  final PaginatedParams params;

  const DomainDeleted(this.domain, this.params);

  @override
  List<Object> get props => [domain, params];

  @override
  String toString() => 'DomainUpdated { domain: $domain params: $params}';
}
