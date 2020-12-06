import 'package:flutter_wine_rate/models/region.dart';
import 'package:flutter_wine_rate/redux/store.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:flutter_wine_rate/redux/regions/regions_state.dart';

import '../../config.dart';

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

Future<void> addRegionAction(
    Store<AppState> store, Config config, Region region) async {
  store.dispatch(SetRegionsStateAction(RegionsState(isLoading: true)));

  try {
    await region.add(config);
    final newRegions = [...store.state.regionsState.regions, region];
    store.dispatch(SetRegionsStateAction(
        RegionsState(isLoading: false, regions: newRegions)));
  } catch (error) {
    store.dispatch(SetRegionsStateAction(RegionsState(isLoading: false)));
  }
}

Future<void> updateRegionAction(
    Store<AppState> store, Config config, Region region) async {
  store.dispatch(SetRegionsStateAction(RegionsState(isLoading: true)));

  try {
    await region.update(config);
    final newRegions = store.state.regionsState.regions
        .map((e) => e.id == region.id ? region : e)
        .toList();
    store.dispatch(SetRegionsStateAction(
        RegionsState(isLoading: false, regions: newRegions)));
  } catch (error) {
    store.dispatch(SetRegionsStateAction(RegionsState(isLoading: false)));
  }
}

Future<void> removeRegionAction(
    Store<AppState> store, Config config, Region region) async {
  store.dispatch(SetRegionsStateAction(RegionsState(isLoading: true)));

  try {
    await region.remove(config);
    final newRegions = store.state.regionsState.regions
        .where((element) => element.id != region.id)
        .toList();
    store.dispatch(SetRegionsStateAction(
        RegionsState(isLoading: false, regions: newRegions)));
  } catch (error) {
    store.dispatch(SetRegionsStateAction(RegionsState(isLoading: false)));
  }
}
