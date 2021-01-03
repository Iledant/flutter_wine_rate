import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/pagination.dart';
import '../repo/region_repo.dart';
import 'regions.dart';

class RegionsBloc extends Bloc<RegionsEvent, RegionsState> {
  final RegionRepository regionRepository;

  RegionsBloc({@required this.regionRepository}) : super(RegionsEmpty());

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
      final regions = await this.regionRepository.getPaginated(params);
      yield RegionsLoadSuccess(regions);
    } catch (_) {
      yield RegionsLoadFailure();
    }
  }

  Stream<RegionsState> _mapRegionAddedToState(RegionAdded event) async* {
    if (state is RegionsLoadSuccess) {
      try {
        yield RegionsLoadInProgress();
        await this.regionRepository.add(event.region);
        final regions = await this.regionRepository.getPaginated(event.params);
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
        await this.regionRepository.update(event.region);
        final regions = await this.regionRepository.getPaginated(event.params);
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
        await this.regionRepository.remove(event.region);
        final regions = await this.regionRepository.getPaginated(event.params);
        yield RegionsLoadSuccess(regions);
      } catch (_) {
        yield RegionsLoadFailure();
      }
    }
  }
}
