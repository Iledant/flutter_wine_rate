import 'package:equatable/equatable.dart';
import '../models/wine.dart';

abstract class PickWinesState extends Equatable {
  const PickWinesState();

  @override
  List<Object> get props => [];
}

class PickWinesEmpty extends PickWinesState {}

class PickWinesLoadInProgress extends PickWinesState {}

class PickWinesLoadSuccess extends PickWinesState {
  final List<Wine> wines;

  const PickWinesLoadSuccess([this.wines = const []]);

  @override
  List<Object> get props => [wines];

  @override
  String toString() => 'PickWinesLoadSuccess { wines: $wines }';
}

class PickWinesLoadFailure extends PickWinesState {}
