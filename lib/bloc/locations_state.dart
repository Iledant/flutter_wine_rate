import 'package:equatable/equatable.dart';
import '../repo/location_repo.dart';

abstract class LocationsState extends Equatable {
  const LocationsState();

  @override
  List<Object> get props => [];
}

class LocationsEmpty extends LocationsState {}

class LocationsLoadInProgress extends LocationsState {}

class LocationsLoadSuccess extends LocationsState {
  final PaginatedLocations locations;

  const LocationsLoadSuccess(
      [this.locations = const PaginatedLocations(
          actualLine: 1, totalLines: 0, lines: const [])]);

  @override
  List<Object> get props => [locations];

  @override
  String toString() => 'LocationsLoadSuccess { locations: $locations }';
}

class LocationsLoadFailure extends LocationsState {}
