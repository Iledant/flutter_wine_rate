import 'package:meta/meta.dart';
import 'package:flutter_wine_rate/models/region.dart';

@immutable
class RegionsState {
  final bool isError;
  final bool isLoading;
  final List<Region> regions;

  RegionsState({this.isError, this.isLoading, this.regions});

  factory RegionsState.initial() =>
      RegionsState(isLoading: false, isError: false, regions: const []);

  RegionsState copyWith(
      {@required bool isError,
      @required bool isLoading,
      @required List<Region> regions}) {
    return RegionsState(
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      regions: regions ?? this.regions,
    );
  }
}
