import 'package:equatable/equatable.dart';
import '../models/critic.dart';

abstract class PickCriticsState extends Equatable {
  const PickCriticsState();

  @override
  List<Object> get props => [];
}

class PickCriticsEmpty extends PickCriticsState {}

class PickCriticsLoadInProgress extends PickCriticsState {}

class PickCriticsLoadSuccess extends PickCriticsState {
  final List<Critic> critics;

  const PickCriticsLoadSuccess([this.critics = const []]);

  @override
  List<Object> get props => [critics];

  @override
  String toString() => 'PickCriticsLoadSuccess { critics: $critics }';
}

class PickCriticsLoadFailure extends PickCriticsState {}
