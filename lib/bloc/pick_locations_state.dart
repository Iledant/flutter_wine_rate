import 'package:equatable/equatable.dart';
import '../models/location.dart';

abstract class PickLocationsState extends Equatable {
  const PickLocationsState();

  @override
  List<Object> get props => [];
}

class PickLocationsEmpty extends PickLocationsState {}

class PickLocationsLoadInProgress extends PickLocationsState {}

class PickLocationsLoadSuccess extends PickLocationsState {
  final List<Location> domains;

  const PickLocationsLoadSuccess([this.domains = const []]);

  @override
  List<Object> get props => [domains];

  @override
  String toString() => 'PickLocationsLoadSuccess { domains: $domains }';
}

class PickLocationsLoadFailure extends PickLocationsState {}
