import 'package:equatable/equatable.dart';

abstract class PickLocationsEvent extends Equatable {
  const PickLocationsEvent();

  @override
  List<Object> get props => [];
}

class PicklocationsClear extends PickLocationsEvent {}

class PickLocationsLoaded extends PickLocationsEvent {
  final String pattern;

  const PickLocationsLoaded(this.pattern);

  @override
  List<Object> get props => [pattern];

  @override
  String toString() => 'PickLocationsLoaded { pattern: $pattern }';
}
