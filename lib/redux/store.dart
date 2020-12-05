import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:flutter_wine_rate/redux/regions/regions_actions.dart';
import 'package:flutter_wine_rate/redux/regions/regions_reducer.dart';
import 'package:flutter_wine_rate/redux/regions/regions_state.dart';
import 'package:redux_thunk/redux_thunk.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is SetRegionsStateAction) {
    final nextRegionsState = regionsReducer(state.regionsState, action);

    return state.copyWith(regionsState: nextRegionsState);
  }
  return state;
}

@immutable
class AppState {
  final RegionsState regionsState;

  AppState({
    @required this.regionsState,
  });

  AppState copyWith({
    RegionsState regionsState,
  }) {
    return AppState(
      regionsState: regionsState ?? this.regionsState,
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

    _store = Store<AppState>(
      appReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(regionsState: regionsStateInital),
    );
  }
}
