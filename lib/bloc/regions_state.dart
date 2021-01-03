import 'package:equatable/equatable.dart';
import '../repo/region_repo.dart';

abstract class RegionsState extends Equatable {
  const RegionsState();

  @override
  List<Object> get props => [];
}

class RegionsEmpty extends RegionsState {}

class RegionsLoadInProgress extends RegionsState {}

class RegionsLoadSuccess extends RegionsState {
  final PaginatedRegions regions;

  const RegionsLoadSuccess(
      [this.regions = const PaginatedRegions(
          actualLine: 1, totalLines: 0, lines: const [])]);

  @override
  List<Object> get props => [regions];

  @override
  String toString() => 'RegionsLoadSuccess { regions: $regions }';
}

class RegionsLoadFailure extends RegionsState {}
