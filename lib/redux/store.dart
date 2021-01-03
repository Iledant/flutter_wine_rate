import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import 'wine_state.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is SetWinesStateAction) {
    final nextWinesState = winesReducer(state.wines, action);

    return state.copyWith(wines: nextWinesState);
  }
  return state;
}

@immutable
class AppState {
  final WinesState wines;

  AppState({
    @required this.wines,
  });

  AppState copyWith({WinesState wines}) {
    return AppState(
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
    final winesStateInitial = WinesState.initial();

    _store = Store<AppState>(
      appReducer,
      middleware: [thunkMiddleware],
      initialState: AppState(
        wines: winesStateInitial,
      ),
    );
  }
}
