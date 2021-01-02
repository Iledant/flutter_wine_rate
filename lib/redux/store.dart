import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'regions_state.dart';
import 'locations_state.dart';
import 'wine_state.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is SetRegionsStateAction) {
    final nextRegionsState = regionsReducer(state.regions, action);

    return state.copyWith(regions: nextRegionsState);
  }
  if (action is SetLocationsStateAction) {
    final nextLocationsState = locationsReducer(state.locations, action);

    return state.copyWith(locations: nextLocationsState);
  }
  if (action is SetWinesStateAction) {
    final nextWinesState = winesReducer(state.wines, action);

    return state.copyWith(locations: nextWinesState);
  }
  return state;
}

@immutable
class AppState {
  final RegionsState regions;
  final LocationsState locations;
  final WinesState wines;

  AppState({
    @required this.regions,
    @required this.locations,
    @required this.wines,
  });

  AppState copyWith(
      {RegionsState regions, LocationsState locations, WinesState wines}) {
    return AppState(
      regions: regions ?? this.regions,
      locations: locations ?? this.locations,
      wines: wines ?? this.wines,
    );
  }
}

class Redux {
  static Store<AppState> _store;

  static Store<AppState> get store {
    if (_store == null) {
      throw Exception('store non initialisé');
    } else {
      return _store;
    }
  }

  static Future<void> init() async {
    final regionsStateInital = RegionsState.initial();
    final locationsStateInitial = LocationsState.initial();
    final winesStateInitial = WinesState.initial();

    _store = Store<AppState>(
      appReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        regions: regionsStateInital,
        locations: locationsStateInitial,
        wines: winesStateInitial,
      ),
    );
  }
}
