import 'package:equatable/equatable.dart';
import '../models/location.dart';

abstract class PickLocationsState extends Equatable {
  const PickLocationsState();

  @override
  List<Object> get props => [];
}

class PickLocationsEmpty extends PickLocationsState {}

class PickLocationsLoadInProgress extends PickLocationsState {}

class PickLocationsLoadSuccess extends PickLocationsState {
  final List<Location> locations;

  const PickLocationsLoadSuccess([this.locations = const []]);

  @override
  List<Object> get props => [locations];

  @override
  String toString() => 'PickLocationsLoadSuccess { domains: $locations }';
}

class PickLocationsLoadFailure extends PickLocationsState {}
