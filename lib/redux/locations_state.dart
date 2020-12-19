import 'package:meta/meta.dart';
import 'package:redux/redux.dart';

import '../models/pagination.dart';
import '../models/location.dart';
import 'store.dart';
import '../config.dart';

@immutable
class LocationsState {
  final bool isError;
  final bool isLoading;
  final List<Location> locations;
  final PaginatedLocations paginatedLocations;

  LocationsState(
      {this.isError, this.isLoading, this.locations, this.paginatedLocations});

  factory LocationsState.initial() => LocationsState(
      isLoading: false,
      isError: false,
      locations: const [],
      paginatedLocations: PaginatedLocations(1, 0, []));

  LocationsState copyWith(
      {@required bool isError,
      @required bool isLoading,
      @required List<Location> locations,
      @required PaginatedLocations paginatedLocations}) {
    return LocationsState(
        isError: isError ?? this.isError,
        isLoading: isLoading ?? this.isLoading,
        locations: locations ?? this.locations,
        paginatedLocations: paginatedLocations ?? this.paginatedLocations);
  }
}

@immutable
class SetLocationsStateAction {
  final LocationsState locations;

  SetLocationsStateAction(this.locations);
}

Future<void> fetchLocationsAction(Store<AppState> store, Config config) async {
  store.dispatch(SetLocationsStateAction(LocationsState(isLoading: true)));

  try {
    final locations = await Location.getAll(config);
    store.dispatch(SetLocationsStateAction(
        LocationsState(isLoading: false, locations: locations)));
  } catch (error) {
    store.dispatch(SetLocationsStateAction(LocationsState(isLoading: false)));
  }
}

Future<void> fetchPaginatedLocationsAction(
    Store<AppState> store, Config config, PaginatedParams params) async {
  store.dispatch(SetLocationsStateAction(LocationsState(isLoading: true)));
  try {
    final paginatedLocations = await Location.getPaginated(config, params);
    store.dispatch(SetLocationsStateAction(LocationsState(
        isLoading: false, paginatedLocations: paginatedLocations)));
  } catch (error) {
    store.dispatch(SetLocationsStateAction(LocationsState(isLoading: false)));
  }
}

Future<void> addLocationAction(
    Store<AppState> store, Config config, Location location) async {
  store.dispatch(SetLocationsStateAction(LocationsState(isLoading: true)));

  try {
    await location.add(config);
    final actualPaginatedLocations = store.state.locations.paginatedLocations;
    final newLocations = [...actualPaginatedLocations.locations, location];
    final newPaginatedLocations = PaginatedLocations(
        actualPaginatedLocations.actualLine,
        actualPaginatedLocations.totalLines,
        newLocations);
    store.dispatch(SetLocationsStateAction(LocationsState(
        isLoading: false, paginatedLocations: newPaginatedLocations)));
  } catch (error) {
    store.dispatch(SetLocationsStateAction(LocationsState(isLoading: false)));
  }
}

Future<void> updateLocationAction(
    Store<AppState> store, Config config, Location location) async {
  store.dispatch(SetLocationsStateAction(LocationsState(isLoading: true)));

  try {
    await location.update(config);
    final actualPaginatedLocations = store.state.locations.paginatedLocations;
    final newLocations = actualPaginatedLocations.locations
        .map((e) => e.id == location.id ? location : e)
        .toList();
    final newPaginatedLocations = PaginatedLocations(
        actualPaginatedLocations.actualLine,
        actualPaginatedLocations.totalLines,
        newLocations);
    store.dispatch(SetLocationsStateAction(LocationsState(
        isLoading: false, paginatedLocations: newPaginatedLocations)));
  } catch (error) {
    store.dispatch(SetLocationsStateAction(LocationsState(isLoading: false)));
  }
}

Future<void> removeLocationAction(Store<AppState> store, Config config,
    Location location, PaginatedParams params) async {
  store.dispatch(SetLocationsStateAction(LocationsState(isLoading: true)));

  try {
    await location.remove(config);
    fetchPaginatedLocationsAction(store, config, params);
  } catch (error) {
    store.dispatch(SetLocationsStateAction(LocationsState(isLoading: false)));
  }
}

locationsReducer(LocationsState prevState, SetLocationsStateAction action) {
  final payload = action.locations;
  return prevState.copyWith(
      isError: payload.isError,
      isLoading: payload.isLoading,
      locations: payload.locations,
      paginatedLocations: payload.paginatedLocations);
}
