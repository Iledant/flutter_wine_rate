import 'package:equatable/equatable.dart';
import 'package:flutter_wine_rate/repo/critic_repo.dart';

abstract class CriticsState extends Equatable {
  const CriticsState();

  @override
  List<Object> get props => [];
}

class CriticsLoadInProgress extends CriticsState {}

class CriticsLoadSuccess extends CriticsState {
  final PaginatedCritics critics;

  const CriticsLoadSuccess(
      [this.critics = const PaginatedCritics(
          actualLine: 1, totalLines: 0, lines: const [])]);

  @override
  List<Object> get props => [critics];

  @override
  String toString() => 'CriticsLoadSuccess { critics: $critics }';
}

class CriticsLoadFailure extends CriticsState {}
