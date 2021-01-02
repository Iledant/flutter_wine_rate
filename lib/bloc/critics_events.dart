import 'package:equatable/equatable.dart';
import '../models/pagination.dart';
import '../models/critic.dart';

abstract class CriticsEvent extends Equatable {
  const CriticsEvent();

  @override
  List<Object> get props => [];
}

class CriticsLoaded extends CriticsEvent {
  final PaginatedParams params;

  const CriticsLoaded(this.params);
}

class CriticAdded extends CriticsEvent {
  final Critic critic;
  final PaginatedParams params;

  const CriticAdded(this.critic, this.params);

  @override
  List<Object> get props => [critic];

  @override
  String toString() => 'CriticsAdded { critic : $critic }';
}

class CriticUpdated extends CriticsEvent {
  final Critic critic;
  final PaginatedParams params;

  const CriticUpdated(this.critic, this.params);

  @override
  List<Object> get props => [critic];

  @override
  String toString() => 'CriticUpdated { critic: $critic }';
}

class CriticDeleted extends CriticsEvent {
  final Critic critic;
  final PaginatedParams params;

  const CriticDeleted(this.critic, this.params);

  @override
  List<Object> get props => [critic];

  @override
  String toString() => 'CriticDeleted { critic: $critic }';
}
