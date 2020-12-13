import 'critics_actions.dart';
import 'critics_state.dart';

criticsReducer(CriticsState prevState, SetCriticsStateAction action) {
  final payload = action.criticsState;
  return prevState.copyWith(
      isError: payload.isError,
      isLoading: payload.isLoading,
      critics: payload.critics,
      paginatedCritics: payload.paginatedCritics);
}
