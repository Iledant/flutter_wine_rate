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
    final results = await config
        .query("SELECT id,name FROM region")
        .then((results) => results.map((e) => Region(e[0], e[1])).toList());
    store.dispatch(SetRegionsStateAction(
        RegionsState(isLoading: false, regions: results)));
  } catch (error) {
    store.dispatch(SetRegionsStateAction(RegionsState(isLoading: false)));
  }
}

Future<void> addRegionAction(
    Store<AppState> store, Config config, Region region) async {
  store.dispatch(SetRegionsStateAction(RegionsState(isLoading: true)));

  try {
    final results = await config.query(
        "INSERT INTO region (name) VALUES (@name) RETURNING id",
        values: {"name": region.name});
    region.id = results[0][0];
    final newRegions = [...store.state.regionsState.regions, region];
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
    await config
        .query("DELETE FROM region WHERE id=@id", values: {"id": region.id});
    final newRegions = store.state.regionsState.regions
        .where((element) => element.id != region.id)
        .toList();
    store.dispatch(SetRegionsStateAction(
        RegionsState(isLoading: false, regions: newRegions)));
  } catch (error) {
    store.dispatch(SetRegionsStateAction(RegionsState(isLoading: false)));
  }
}
