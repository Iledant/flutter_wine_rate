import 'dart:async';
import 'package:bloc/bloc.dart';

import '../models/pagination.dart';
import '../repo/location_repo.dart';
import 'locations.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  LocationsBloc() : super(LocationsEmpty());

  @override
  Stream<LocationsState> mapEventToState(LocationsEvent event) async* {
    if (event is LocationsLoaded) {
      yield* _mapLocationsLoadedToState(event.params);
    } else if (event is LocationAdded) {
      yield* _mapLocationAddedToState(event);
    } else if (event is LocationUpdated) {
      yield* _mapLocationUpdatedToState(event);
    } else if (event is LocationDeleted) {
      yield* _mapLocationDeletedToState(event);
    }
  }

  Stream<LocationsState> _mapLocationsLoadedToState(
      PaginatedParams params) async* {
    try {
      yield LocationsLoadInProgress();
      final locations = await LocationRepository.getPaginated(params);
      yield LocationsLoadSuccess(locations);
    } catch (_) {
      yield LocationsLoadFailure();
    }
  }

  Stream<LocationsState> _mapLocationAddedToState(LocationAdded event) async* {
    if (state is LocationsLoadSuccess) {
      try {
        yield LocationsLoadInProgress();
        await LocationRepository.add(event.location);
        final locations = await LocationRepository.getPaginated(event.params);
        yield LocationsLoadSuccess(locations);
      } catch (_) {
        yield LocationsLoadFailure();
      }
    }
  }

  Stream<LocationsState> _mapLocationUpdatedToState(
      LocationUpdated event) async* {
    if (state is LocationsLoadSuccess) {
      try {
        yield LocationsLoadInProgress();
        await LocationRepository.update(event.location);
        final locations = await LocationRepository.getPaginated(event.params);
        yield LocationsLoadSuccess(locations);
      } catch (_) {
        yield LocationsLoadFailure();
      }
    }
  }

  Stream<LocationsState> _mapLocationDeletedToState(
      LocationDeleted event) async* {
    if (state is LocationsLoadSuccess) {
      try {
        yield LocationsLoadInProgress();
        await LocationRepository.remove(event.location);
        final locations = await LocationRepository.getPaginated(event.params);
        yield LocationsLoadSuccess(locations);
      } catch (_) {
        yield LocationsLoadFailure();
      }
    }
  }
}
