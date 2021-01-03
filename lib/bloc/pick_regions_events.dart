import 'package:equatable/equatable.dart';

abstract class PickRegionsEvent extends Equatable {
  const PickRegionsEvent();

  @override
  List<Object> get props => [];
}

class PickRegionsLoaded extends PickRegionsEvent {
  final String pattern;

  const PickRegionsLoaded(this.pattern);

  @override
  List<Object> get props => [pattern];

  @override
  String toString() => 'PickRegionsLoaded { pattern: $pattern }';
}
