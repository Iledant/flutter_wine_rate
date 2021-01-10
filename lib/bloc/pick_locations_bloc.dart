import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../repo/location_repo.dart';
import 'pick_locations.dart';

class PickLocationsBloc extends Bloc<PickLocationsEvent, PickLocationsState> {
  final LocationRepository locationRepository;

  PickLocationsBloc({@required this.locationRepository})
      : super(PickLocationsEmpty());

  @override
  Stream<PickLocationsState> mapEventToState(PickLocationsEvent event) async* {
    if (event is PickLocationsLoaded) {
      yield* _mapPickLocationsLoadedToState(event.pattern);
    } else if (event is PicklocationsClear) {
      yield* _mapPickLocationsClearToState();
    }
  }

  Stream<PickLocationsState> _mapPickLocationsLoadedToState(
      String pattern) async* {
    try {
      yield PickLocationsLoadInProgress();
      final locations = await this.locationRepository.getFirstFive(pattern);
      yield PickLocationsLoadSuccess(locations);
    } catch (_) {
      yield PickLocationsLoadFailure();
    }
  }

  Stream<PickLocationsState> _mapPickLocationsClearToState() async* {
    try {
      yield PickLocationsLoadSuccess(const []);
    } catch (_) {
      yield PickLocationsLoadFailure();
    }
  }
}
