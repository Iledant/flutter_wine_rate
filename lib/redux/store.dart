import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'locations_state.dart';
import 'wine_state.dart';

AppState appReducer(AppState state, dynamic action) {
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
  final LocationsState locations;
  final WinesState wines;

  AppState({
    @required this.locations,
    @required this.wines,
  });

  AppState copyWith({LocationsState locations, WinesState wines}) {
    return AppState(
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
    final locationsStateInitial = LocationsState.initial();
    final winesStateInitial = WinesState.initial();

    _store = Store<AppState>(
      appReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        locations: locationsStateInitial,
        wines: winesStateInitial,
      ),
    );
  }
}
