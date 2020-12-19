import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'critics_state.dart';
import 'regions_state.dart';
import 'domains_state.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is SetRegionsStateAction) {
    final nextRegionsState = regionsReducer(state.regions, action);

    return state.copyWith(regions: nextRegionsState);
  }
  if (action is SetCriticsStateAction) {
    final nextCriticsState = criticsReducer(state.critics, action);

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
  final RegionsState regions;
  final CriticsState critics;
  final DomainsState domainsState;

  AppState(
      {@required this.regions,
      @required this.critics,
      @required this.domainsState});

  AppState copyWith(
      {RegionsState regions,
      CriticsState criticsState,
      DomainsState domainsState}) {
    return AppState(
      regions: regions ?? this.regions,
      critics: criticsState ?? this.critics,
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
        regions: regionsStateInital,
        critics: criticsStateInital,
        domainsState: domainsStateInitial,
      ),
    );
  }
}
