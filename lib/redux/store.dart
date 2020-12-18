import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:flutter_wine_rate/redux/regions/regions_actions.dart';
import 'package:flutter_wine_rate/redux/regions/regions_reducer.dart';
import 'package:flutter_wine_rate/redux/regions/regions_state.dart';
import 'package:flutter_wine_rate/redux/critics/critics_actions.dart';
import 'package:flutter_wine_rate/redux/critics/critics_reducer.dart';
import 'package:flutter_wine_rate/redux/critics/critics_state.dart';
import 'package:flutter_wine_rate/redux/domains/domains_actions.dart';
import 'package:flutter_wine_rate/redux/domains/domains_reducer.dart';
import 'package:flutter_wine_rate/redux/domains/domains_state.dart';
import 'package:redux_thunk/redux_thunk.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is SetRegionsStateAction) {
    final nextRegionsState = regionsReducer(state.regionsState, action);

    return state.copyWith(regionsState: nextRegionsState);
  }
  if (action is SetCriticsStateAction) {
    final nextCriticsState = criticsReducer(state.criticsState, action);

    return state.copyWith(criticsState: nextCriticsState);
  }
  if (action is SetDomainsStateAction) {
    final nextDomainsState = domainsReducer(state.domainsState, action);

    return state.copyWith(domainsState: nextDomainsState);
  }
  return state;
}

@immutable
class AppState {
  final RegionsState regionsState;
  final CriticsState criticsState;
  final DomainsState domainsState;

  AppState(
      {@required this.regionsState,
      @required this.criticsState,
      @required this.domainsState});

  AppState copyWith(
      {RegionsState regionsState,
      CriticsState criticsState,
      DomainsState domainsState}) {
    return AppState(
      regionsState: regionsState ?? this.regionsState,
      criticsState: criticsState ?? this.criticsState,
      domainsState: domainsState ?? this.domainsState,
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
    final criticsStateInital = CriticsState.initial();
    final domainsStateInitial = DomainsState.initial();

    _store = Store<AppState>(
      appReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        regionsState: regionsStateInital,
        criticsState: criticsStateInital,
        domainsState: domainsStateInitial,
      ),
    );
  }
}
