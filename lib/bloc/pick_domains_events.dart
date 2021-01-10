import 'package:equatable/equatable.dart';

abstract class PickDomainsEvent extends Equatable {
  const PickDomainsEvent();

  @override
  List<Object> get props => [];
}

class PickDomainsLoaded extends PickDomainsEvent {
  final String pattern;

  const PickDomainsLoaded(this.pattern);

  @override
  List<Object> get props => [pattern];

  @override
  String toString() => 'PickDomainsLoaded { pattern: $pattern }';
}

class PickDomainsClear extends PickDomainsEvent {}
