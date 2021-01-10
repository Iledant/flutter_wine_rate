import 'package:equatable/equatable.dart';

abstract class PickWinesEvent extends Equatable {
  const PickWinesEvent();

  @override
  List<Object> get props => [];
}

class PickWinesLoaded extends PickWinesEvent {
  final String pattern;

  const PickWinesLoaded(this.pattern);

  @override
  List<Object> get props => [pattern];

  @override
  String toString() => 'PickWinesLoaded { pattern: $pattern }';
}

class PickWinesClear extends PickWinesEvent {}
