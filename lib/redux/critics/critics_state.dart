import 'package:flutter_wine_rate/models/critic.dart';
import 'package:meta/meta.dart';

@immutable
class CriticsState {
  final bool isError;
  final bool isLoading;
  final List<Critic> critics;
  final PaginatedCritics paginatedCritics;

  CriticsState(
      {this.isError, this.isLoading, this.critics, this.paginatedCritics});

  factory CriticsState.initial() => CriticsState(
      isLoading: false,
      isError: false,
      critics: const [],
      paginatedCritics: PaginatedCritics(1, 0, []));

  CriticsState copyWith(
      {@required bool isError,
      @required bool isLoading,
      @required List<Critic> critics,
      @required PaginatedCritics paginatedCritics}) {
    return CriticsState(
        isError: isError ?? this.isError,
        isLoading: isLoading ?? this.isLoading,
        critics: critics ?? this.critics,
        paginatedCritics: paginatedCritics ?? this.paginatedCritics);
  }
}
