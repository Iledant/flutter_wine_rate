import 'package:equatable/equatable.dart';

abstract class PickCriticsEvent extends Equatable {
  const PickCriticsEvent();

  @override
  List<Object> get props => [];
}

class PickCriticsLoaded extends PickCriticsEvent {
  final String pattern;

  const PickCriticsLoaded(this.pattern);

  @override
  List<Object> get props => [pattern];

  @override
  String toString() => 'PickCriticsLoaded { pattern: $pattern }';
}

class PickCriticsClear extends PickCriticsEvent {}
