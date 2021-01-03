import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/pagination.dart';
import '../repo/location_repo.dart';
import 'locations.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  final LocationRepository locationRepository;

  LocationsBloc({@required this.locationRepository}) : super(LocationsEmpty());

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
      final locations = await this.locationRepository.getPaginated(params);
      yield LocationsLoadSuccess(locations);
    } catch (_) {
      yield LocationsLoadFailure();
    }
  }

  Stream<LocationsState> _mapLocationAddedToState(LocationAdded event) async* {
    if (state is LocationsLoadSuccess) {
      try {
        yield LocationsLoadInProgress();
        await this.locationRepository.add(event.location);
        final locations =
            await this.locationRepository.getPaginated(event.params);
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
        await this.locationRepository.update(event.location);
        final locations =
            await this.locationRepository.getPaginated(event.params);
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
        await this.locationRepository.remove(event.location);
        final locations =
            await this.locationRepository.getPaginated(event.params);
        yield LocationsLoadSuccess(locations);
      } catch (_) {
        yield LocationsLoadFailure();
      }
    }
  }
}
