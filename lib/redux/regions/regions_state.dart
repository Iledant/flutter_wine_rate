import 'package:meta/meta.dart';
import 'package:flutter_wine_rate/models/region.dart';

@immutable
class RegionsState {
  final bool isError;
  final bool isLoading;
  final List<Region> regions;
  final PaginatedRegions paginatedRegions;

  RegionsState(
      {this.isError, this.isLoading, this.regions, this.paginatedRegions});

  factory RegionsState.initial() => RegionsState(
      isLoading: false,
      isError: false,
      regions: const [],
      paginatedRegions: PaginatedRegions(1, 0, []));

  RegionsState copyWith(
      {@required bool isError,
      @required bool isLoading,
      @required List<Region> regions,
      @required PaginatedRegions paginatedRegions}) {
    return RegionsState(
        isError: isError ?? this.isError,
        isLoading: isLoading ?? this.isLoading,
        regions: regions ?? this.regions,
        paginatedRegions: paginatedRegions ?? this.paginatedRegions);
  }
}
