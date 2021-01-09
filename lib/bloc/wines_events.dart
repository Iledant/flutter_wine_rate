import 'package:equatable/equatable.dart';
import '../models/pagination.dart';
import '../models/wine.dart';

abstract class WinesEvent extends Equatable {
  const WinesEvent();

  @override
  List<Object> get props => [];
}

class WinesLoaded extends WinesEvent {
  final PaginatedParams params;

  const WinesLoaded(this.params);

  @override
  List<Object> get props => [params];

  @override
  String toString() => 'WinesLoaded { params: $params }';
}

class WineAdded extends WinesEvent {
  final Wine wine;
  final PaginatedParams params;

  const WineAdded(this.wine, this.params);

  @override
  List<Object> get props => [wine, params];

  @override
  String toString() => 'WineUpdated { wine: $wine params: $params}';
}

class WineUpdated extends WinesEvent {
  final Wine wine;
  final PaginatedParams params;

  const WineUpdated(this.wine, this.params);

  @override
  List<Object> get props => [wine, params];

  @override
  String toString() => 'WineUpdated { wine: $wine params: $params}';
}

class WineDeleted extends WinesEvent {
  final Wine wine;
  final PaginatedParams params;

  const WineDeleted(this.wine, this.params);

  @override
  List<Object> get props => [wine, params];

  @override
  String toString() => 'WineUpdated { wine: $wine params: $params}';
}
