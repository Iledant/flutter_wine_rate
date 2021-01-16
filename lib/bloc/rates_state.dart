import 'package:equatable/equatable.dart';
import '../repo/rate_repo.dart';

abstract class RatesState extends Equatable {
  const RatesState();

  @override
  List<Object> get props => [];
}

class RatesEmpty extends RatesState {}

class RatesLoadInProgress extends RatesState {}

class RatesLoadSuccess extends RatesState {
  final PaginatedRates rates;

  const RatesLoadSuccess(
      [this.rates =
          const PaginatedRates(actualLine: 1, totalLines: 0, lines: const [])]);

  @override
  List<Object> get props => [rates];

  @override
  String toString() => 'RatesLoadSuccess { rates: $rates }';
}

class RatesLoadFailure extends RatesState {}
