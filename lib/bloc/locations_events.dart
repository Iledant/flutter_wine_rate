
import 'package:equatable/equatable.dart';
import '../models/pagination.dart';
import '../models/location.dart';

abstract class LocationsEvent extends Equatable {
  const LocationsEvent();

  @override
  List<Object> get props => [];
}

class LocationsLoaded extends LocationsEvent {
  final PaginatedParams params;

  const LocationsLoaded(this.params);

  @override
  List<Object> get props => [params];

  @override
  String toString() => 'LocationsLoaded { params: $params }';
}

class LocationAdded extends LocationsEvent {
  final Location location;
  final PaginatedParams params;

  const LocationAdded(this.location, this.params);

  @override
  List<Object> get props => [location, params];

  @override
  String toString() => 'LocationUpdated { location: $location params: $params}';
}

class LocationUpdated extends LocationsEvent {
  final Location location;
  final PaginatedParams params;

  const LocationUpdated(this.location, this.params);

  @override
  List<Object> get props => [location, params];

  @override
  String toString() => 'LocationUpdated { location: $location params: $params}';
}

class LocationDeleted extends LocationsEvent {
  final Location location;
  final PaginatedParams params;

  const LocationDeleted(this.location, this.params);

  @override
  List<Object> get props => [location, params];

  @override
  String toString() => 'LocationUpdated { location: $location params: $params}';
}
