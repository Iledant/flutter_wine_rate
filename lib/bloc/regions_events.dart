import 'package:equatable/equatable.dart';
import '../models/pagination.dart';
import '../models/region.dart';

abstract class RegionsEvent extends Equatable {
  const RegionsEvent();

  @override
  List<Object> get props => [];
}

class RegionsLoaded extends RegionsEvent {
  final PaginatedParams params;

  const RegionsLoaded(this.params);

  @override
  List<Object> get props => [params];

  @override
  String toString() => 'RegionsLoaded { params: $params }';
}

class RegionAdded extends RegionsEvent {
  final Region region;
  final PaginatedParams params;

  const RegionAdded(this.region, this.params);

  @override
  List<Object> get props => [region, params];

  @override
  String toString() => 'RegionUpdated { region: $region params: $params}';
}

class RegionUpdated extends RegionsEvent {
  final Region region;
  final PaginatedParams params;

  const RegionUpdated(this.region, this.params);

  @override
  List<Object> get props => [region, params];

  @override
  String toString() => 'RegionUpdated { region: $region params: $params}';
}

class RegionDeleted extends RegionsEvent {
  final Region region;
  final PaginatedParams params;

  const RegionDeleted(this.region, this.params);

  @override
  List<Object> get props => [region, params];

  @override
  String toString() => 'RegionUpdated { region: $region params: $params}';
}
