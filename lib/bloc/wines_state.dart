import 'package:equatable/equatable.dart';
import '../repo/wine_repo.dart';

abstract class WinesState extends Equatable {
  const WinesState();

  @override
  List<Object> get props => [];
}

class WinesEmpty extends WinesState {}

class WinesLoadInProgress extends WinesState {}

class WinesLoadSuccess extends WinesState {
  final PaginatedWines wines;

  const WinesLoadSuccess(
      [this.wines =
          const PaginatedWines(actualLine: 1, totalLines: 0, lines: const [])]);

  @override
  List<Object> get props => [wines];

  @override
  String toString() => 'WinesLoadSuccess { wines: $wines }';
}

class WinesLoadFailure extends WinesState {}
