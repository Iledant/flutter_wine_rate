import 'package:flutter_wine_rate/models/region.dart';
import 'package:flutter_wine_rate/redux/store.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:flutter_wine_rate/redux/regions/regions_state.dart';

import '../../config.dart';
import '../../paginated_table.dart';

@immutable
class SetRegionsStateAction {
  final RegionsState regionsState;

  SetRegionsStateAction(this.regionsState);
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
    final actualPaginatedRegions = store.state.regionsState.paginatedRegions;
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
    final actualPaginatedRegions = store.state.regionsState.paginatedRegions;
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
