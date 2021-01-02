import 'package:equatable/equatable.dart';
import 'package:flutter_wine_rate/repo/domain_repo.dart';

abstract class DomainsState extends Equatable {
  const DomainsState();

  @override
  List<Object> get props => [];
}

class DomainsEmpty extends DomainsState {}

class DomainsLoadInProgress extends DomainsState {}

class DomainsLoadSuccess extends DomainsState {
  final PaginatedDomains domains;

  const DomainsLoadSuccess(
      [this.domains = const PaginatedDomains(
          actualLine: 1, totalLines: 0, lines: const [])]);

  @override
  List<Object> get props => [domains];

  @override
  String toString() => 'DomainsLoadSuccess { domains: $domains }';
}

class DomainsLoadFailure extends DomainsState {}
