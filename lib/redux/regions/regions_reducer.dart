import 'package:flutter_wine_rate/redux/regions/regions_actions.dart';
import 'package:flutter_wine_rate/redux/regions/regions_state.dart';

regionsReducer(RegionsState prevState, SetRegionsStateAction action) {
  final payload = action.regionsState;
  return prevState.copyWith(
      isError: payload.isError,
      isLoading: payload.isLoading,
      regions: payload.regions,
      paginatedRegions: payload.paginatedRegions);
}
