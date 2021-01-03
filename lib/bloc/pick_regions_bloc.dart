import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../repo/region_repo.dart';
import 'pick_regions.dart';

class PickRegionsBloc extends Bloc<PickRegionsEvent, PickRegionsState> {
  final RegionRepository regionRepository;

  PickRegionsBloc({@required this.regionRepository})
      : super(PickRegionsEmpty());

  @override
  Stream<PickRegionsState> mapEventToState(PickRegionsEvent event) async* {
    if (event is PickRegionsLoaded) {
      yield* _mapPickRegionsLoadedToState(event.pattern);
    }
  }

  Stream<PickRegionsState> _mapPickRegionsLoadedToState(String pattern) async* {
    try {
      yield PickRegionsLoadInProgress();
      final regions = await this.regionRepository.getFirstFive(pattern);
      yield PickRegionsLoadSuccess(regions);
    } catch (_) {
      yield PickRegionsLoadFailure();
    }
  }
}
