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

  @override
  List<Object> get props => [params];

  @override
  String toString() => 'CriticsLoaded { params: $params}';
}

class CriticAdded extends CriticsEvent {
  final Critic critic;
  final PaginatedParams params;

  const CriticAdded(this.critic, this.params);

  @override
  List<Object> get props => [critic, params];

  @override
  String toString() => 'CriticUpdated { critic: $critic params: $params}';
}

class CriticUpdated extends CriticsEvent {
  final Critic critic;
  final PaginatedParams params;

  const CriticUpdated(this.critic, this.params);

  @override
  List<Object> get props => [critic, params];

  @override
  String toString() => 'CriticUpdated { critic: $critic params: $params}';
}

class CriticDeleted extends CriticsEvent {
  final Critic critic;
  final PaginatedParams params;

  const CriticDeleted(this.critic, this.params);

  @override
  List<Object> get props => [critic, params];

  @override
  String toString() => 'CriticUpdated { critic: $critic params: $params}';
}
