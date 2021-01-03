import 'package:equatable/equatable.dart';
import '../models/region.dart';

abstract class PickRegionsState extends Equatable {
  const PickRegionsState();

  @override
  List<Object> get props => [];
}

class PickRegionsEmpty extends PickRegionsState {}

class PickRegionsLoadInProgress extends PickRegionsState {}

class PickRegionsLoadSuccess extends PickRegionsState {
  final List<Region> regions;

  const PickRegionsLoadSuccess([this.regions = const []]);

  @override
  List<Object> get props => [regions];

  @override
  String toString() => 'PickRegionsLoadSuccess { regions: $regions }';
}

class PickRegionsLoadFailure extends PickRegionsState {}
