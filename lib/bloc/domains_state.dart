import 'package:equatable/equatable.dart';
import '../models/domain.dart';
import '../repo/domain_repo.dart';

abstract class DomainsState extends Equatable {
  const DomainsState();

  @override
  List<Object> get props => [];
}

class DomainsEmpty extends DomainsState {}

class DomainsLoadInProgress extends DomainsState {}

class DomainsLoadSuccess extends DomainsState {
  final PaginatedDomains domains;
  final List<Domain> firstFiveDomains;

  const DomainsLoadSuccess(
      [this.domains =
          const PaginatedDomains(actualLine: 1, totalLines: 0, lines: const []),
      this.firstFiveDomains = const []]);

  @override
  List<Object> get props => [domains, firstFiveDomains];

  @override
  String toString() =>
      'DomainsLoadSuccess { domains: $domains, firstFiveDomains: $firstFiveDomains }';
}

class DomainsLoadFailure extends DomainsState {}
