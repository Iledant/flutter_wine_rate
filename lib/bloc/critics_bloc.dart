import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/pagination.dart';
import '../repo/critic_repo.dart';
import './critics.dart';

class CriticsBloc extends Bloc<CriticsEvent, CriticsState> {
  final CriticRepository criticRepository;

  CriticsBloc({@required this.criticRepository}) : super(CriticsEmpty());

  @override
  Stream<CriticsState> mapEventToState(CriticsEvent event) async* {
    if (event is CriticsLoaded) {
      yield* _mapCriticsLoadedToState(event.params);
    } else if (event is CriticAdded) {
      yield* _mapCriticAddedToState(event);
    } else if (event is CriticUpdated) {
      yield* _mapCriticUpdatedToState(event);
    } else if (event is CriticDeleted) {
      yield* _mapCriticDeletedToState(event);
    }
  }

  Stream<CriticsState> _mapCriticsLoadedToState(PaginatedParams params) async* {
    try {
      yield CriticsLoadInProgress();
      final critics = await this.criticRepository.getPaginated(params);
      yield CriticsLoadSuccess(critics);
    } catch (_) {
      yield CriticsLoadFailure();
    }
  }

  Stream<CriticsState> _mapCriticAddedToState(CriticAdded event) async* {
    if (state is CriticsLoadSuccess) {
      try {
        yield CriticsLoadInProgress();
        await this.criticRepository.add(event.critic);
        final critics = await this.criticRepository.getPaginated(event.params);
        yield CriticsLoadSuccess(critics);
      } catch (_) {
        yield CriticsLoadFailure();
      }
    }
  }

  Stream<CriticsState> _mapCriticUpdatedToState(CriticUpdated event) async* {
    if (state is CriticsLoadSuccess) {
      try {
        yield CriticsLoadInProgress();
        await this.criticRepository.update(event.critic);
        final critics = await this.criticRepository.getPaginated(event.params);
        yield CriticsLoadSuccess(critics);
      } catch (_) {
        yield CriticsLoadFailure();
      }
    }
  }

  Stream<CriticsState> _mapCriticDeletedToState(CriticDeleted event) async* {
    if (state is CriticsLoadSuccess) {
      try {
        yield CriticsLoadInProgress();
        await this.criticRepository.remove(event.critic);
        final critics = await this.criticRepository.getPaginated(event.params);
        yield CriticsLoadSuccess(critics);
      } catch (_) {
        yield CriticsLoadFailure();
      }
    }
  }
}
