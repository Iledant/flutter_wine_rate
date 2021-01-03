import 'package:equatable/equatable.dart';
import '../models/domain.dart';
import '../repo/domain_repo.dart';

abstract class PickDomainsState extends Equatable {
  const PickDomainsState();

  @override
  List<Object> get props => [];
}

class PickDomainsEmpty extends PickDomainsState {}

class PickDomainsLoadInProgress extends PickDomainsState {}

class PickDomainsLoadSuccess extends PickDomainsState {
  final List<Domain> domains;

  const PickDomainsLoadSuccess([this.domains = const []]);

  @override
  List<Object> get props => [domains];

  @override
  String toString() => 'PickDomainsLoadSuccess { domains: $domains }';
}

class PickDomainsLoadFailure extends PickDomainsState {}
