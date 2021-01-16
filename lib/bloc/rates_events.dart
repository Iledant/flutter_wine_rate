import 'package:equatable/equatable.dart';
import '../models/pagination.dart';
import '../models/rate.dart';

abstract class RatesEvent extends Equatable {
  const RatesEvent();

  @override
  List<Object> get props => [];
}

class RatesLoaded extends RatesEvent {
  final PaginatedParams params;

  const RatesLoaded(this.params);

  @override
  List<Object> get props => [params];

  @override
  String toString() => 'RatesLoaded { params: $params }';
}

class RateAdded extends RatesEvent {
  final Rate rate;
  final PaginatedParams params;

  const RateAdded(this.rate, this.params);

  @override
  List<Object> get props => [rate, params];

  @override
  String toString() => 'RateUpdated { rate: $rate params: $params}';
}

class RateUpdated extends RatesEvent {
  final Rate rate;
  final PaginatedParams params;

  const RateUpdated(this.rate, this.params);

  @override
  List<Object> get props => [rate, params];

  @override
  String toString() => 'RateUpdated { rate: $rate params: $params}';
}

class RateDeleted extends RatesEvent {
  final Rate rate;
  final PaginatedParams params;

  const RateDeleted(this.rate, this.params);

  @override
  List<Object> get props => [rate, params];

  @override
  String toString() => 'RateUpdated { rate: $rate params: $params}';
}
