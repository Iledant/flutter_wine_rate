import 'package:meta/meta.dart';
import 'package:redux/redux.dart';

import '../models/pagination.dart';
import '../models/region.dart';
import 'store.dart';
import '../config.dart';

@immutable
class RegionsState {
  final bool isError;
  final bool isLoading;
  final List<Region> regions;
  final PaginatedRegions paginatedRegions;

  RegionsState(
      {this.isError, this.isLoading, this.regions, this.paginatedRegions});

  factory RegionsState.initial() => RegionsState(
      isLoading: false,
      isError: false,
      regions: const [],
      paginatedRegions: PaginatedRegions(1, 0, []));

  RegionsState copyWith(
      {@required bool isError,
      @required bool isLoading,
      @required List<Region> regions,
      @required PaginatedRegions paginatedRegions}) {
    return RegionsState(
        isError: isError ?? this.isError,
        isLoading: isLoading ?? this.isLoading,
        regions: regions ?? this.regions,
        paginatedRegions: paginatedRegions ?? this.paginatedRegions);
  }
}

@immutable
class SetRegionsStateAction {
  final RegionsState regions;

  SetRegionsStateAction(this.regions);
}

Future<void> fetchRegionsAction(Store<AppState> store, Config config) async {
  store.dispatch(SetRegionsStateAction(RegionsState(isLoading: true)));

  try {
    final regions = await Region.getAll(config);
    store.dispatch(SetRegionsStateAction(
        RegionsState(isLoading: false, regions: regions)));
  } catch (error) {
    store.dispatch(SetRegionsStateAction(RegionsState(isLoading: false)));
  }
}

Future<void> fetchFirstFiveRegionsAction(
    Store<AppState> store, Config config, String pattern) async {
  store.dispatch(SetRegionsStateAction(RegionsState(isLoading: true)));

  try {
    final regions = await Region.getFirstFive(config, pattern);
    store.dispatch(SetRegionsStateAction(
        RegionsState(isLoading: false, regions: regions)));
  } catch (error) {
    store.dispatch(SetRegionsStateAction(RegionsState(isLoading: false)));
  }
}

Future<void> fetchPaginatedRegionsAction(
    Store<AppState> store, Config config, PaginatedParams params) async {
  store.dispatch(SetRegionsStateAction(RegionsState(isLoading: true)));
  try {
    final paginatedRegions = await Region.getPaginated(config, params);
    store.dispatch(SetRegionsStateAction(
        RegionsState(isLoading: false, paginatedRegions: paginatedRegions)));
  } catch (error) {
    store.dispatch(SetRegionsStateAction(RegionsState(isLoading: false)));
  }
}

Future<void> addRegionAction(
    Store<AppState> store, Config config, Region region) async {
  store.dispatch(SetRegionsStateAction(RegionsState(isLoading: true)));

  try {
    await region.add(config);
    final actualPaginatedRegions = store.state.regions.paginatedRegions;
    final newRegions = [...actualPaginatedRegions.regions, region];
    final newPaginatedRegions = PaginatedRegions(
        actualPaginatedRegions.actualLine,
        actualPaginatedRegions.totalLines,
        newRegions);
    store.dispatch(SetRegionsStateAction(
        RegionsState(isLoading: false, paginatedRegions: newPaginatedRegions)));
  } catch (error) {
    store.dispatch(SetRegionsStateAction(RegionsState(isLoading: false)));
  }
}

Future<void> updateRegionAction(
    Store<AppState> store, Config config, Region region) async {
  store.dispatch(SetRegionsStateAction(RegionsState(isLoading: true)));

  try {
    await region.update(config);
    final actualPaginatedRegions = store.state.regions.paginatedRegions;
    final newRegions = actualPaginatedRegions.regions
        .map((e) => e.id == region.id ? region : e)
        .toList();
    final newPaginatedRegions = PaginatedRegions(
        actualPaginatedRegions.actualLine,
        actualPaginatedRegions.totalLines,
        newRegions);
    store.dispatch(SetRegionsStateAction(
        RegionsState(isLoading: false, paginatedRegions: newPaginatedRegions)));
  } catch (error) {
    store.dispatch(SetRegionsStateAction(RegionsState(isLoading: false)));
  }
}

Future<void> removeRegionAction(Store<AppState> store, Config config,
    Region region, PaginatedParams params) async {
  store.dispatch(SetRegionsStateAction(RegionsState(isLoading: true)));

  try {
    await region.remove(config);
    fetchPaginatedRegionsAction(store, config, params);
  } catch (error) {
    store.dispatch(SetRegionsStateAction(RegionsState(isLoading: false)));
  }
}

regionsReducer(RegionsState prevState, SetRegionsStateAction action) {
  final payload = action.regions;
  return prevState.copyWith(
      isError: payload.isError,
      isLoading: payload.isLoading,
      regions: payload.regions,
      paginatedRegions: payload.paginatedRegions);
}
