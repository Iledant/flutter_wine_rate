import 'dart:async';
import 'package:bloc/bloc.dart';
import '../repo/region_repo.dart';

import 'pick_regions.dart';

class PickRegionsBloc extends Bloc<PickRegionsEvent, PickRegionsState> {
  PickRegionsBloc() : super(PickRegionsEmpty());

  @override
  Stream<PickRegionsState> mapEventToState(PickRegionsEvent event) async* {
    if (event is PickRegionsLoaded) {
      yield* _mapPickRegionsLoadedToState(event.pattern);
    } else if (event is PickRegionsClear) {
      yield* _mapPickRegionsClearToState();
    }
  }

  Stream<PickRegionsState> _mapPickRegionsLoadedToState(String pattern) async* {
    try {
      yield PickRegionsLoadInProgress();
      final regions = await RegionRepository.getFirstFive(pattern);
      yield PickRegionsLoadSuccess(regions);
    } catch (_) {
      yield PickRegionsLoadFailure();
    }
  }

  Stream<PickRegionsState> _mapPickRegionsClearToState() async* {
    yield PickRegionsLoadSuccess();
  }
}
