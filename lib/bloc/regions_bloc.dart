import 'dart:async';
import 'package:bloc/bloc.dart';

import '../models/pagination.dart';
import '../repo/region_repo.dart';
import 'regions.dart';

class RegionsBloc extends Bloc<RegionsEvent, RegionsState> {
  RegionsBloc() : super(RegionsEmpty());

  @override
  Stream<RegionsState> mapEventToState(RegionsEvent event) async* {
    if (event is RegionsLoaded) {
      yield* _mapRegionsLoadedToState(event.params);
    } else if (event is RegionAdded) {
      yield* _mapRegionAddedToState(event);
    } else if (event is RegionUpdated) {
      yield* _mapRegionUpdatedToState(event);
    } else if (event is RegionDeleted) {
      yield* _mapRegionDeletedToState(event);
    }
  }

  Stream<RegionsState> _mapRegionsLoadedToState(PaginatedParams params) async* {
    try {
      yield RegionsLoadInProgress();
      final regions = await RegionRepository.getPaginated(params);
      yield RegionsLoadSuccess(regions);
    } catch (_) {
      yield RegionsLoadFailure();
    }
  }

  Stream<RegionsState> _mapRegionAddedToState(RegionAdded event) async* {
    if (state is RegionsLoadSuccess) {
      try {
        yield RegionsLoadInProgress();
        await RegionRepository.add(event.region);
        final regions = await RegionRepository.getPaginated(event.params);
        yield RegionsLoadSuccess(regions);
      } catch (_) {
        yield RegionsLoadFailure();
      }
    }
  }

  Stream<RegionsState> _mapRegionUpdatedToState(RegionUpdated event) async* {
    if (state is RegionsLoadSuccess) {
      try {
        yield RegionsLoadInProgress();
        await RegionRepository.update(event.region);
        final regions = await RegionRepository.getPaginated(event.params);
        yield RegionsLoadSuccess(regions);
      } catch (_) {
        yield RegionsLoadFailure();
      }
    }
  }

  Stream<RegionsState> _mapRegionDeletedToState(RegionDeleted event) async* {
    if (state is RegionsLoadSuccess) {
      try {
        yield RegionsLoadInProgress();
        await RegionRepository.remove(event.region);
        final regions = await RegionRepository.getPaginated(event.params);
        yield RegionsLoadSuccess(regions);
      } catch (_) {
        yield RegionsLoadFailure();
      }
    }
  }
}
