import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/pagination.dart';
import '../repo/wine_repo.dart';
import 'wines.dart';

class WinesBloc extends Bloc<WinesEvent, WinesState> {
  final WineRepository wineRepository;

  WinesBloc({@required this.wineRepository}) : super(WinesEmpty());

  @override
  Stream<WinesState> mapEventToState(WinesEvent event) async* {
    if (event is WinesLoaded) {
      yield* _mapWinesLoadedToState(event.params);
    } else if (event is WineAdded) {
      yield* _mapWineAddedToState(event);
    } else if (event is WineUpdated) {
      yield* _mapWineUpdatedToState(event);
    } else if (event is WineDeleted) {
      yield* _mapWineDeletedToState(event);
    }
  }

  Stream<WinesState> _mapWinesLoadedToState(PaginatedParams params) async* {
    try {
      yield WinesLoadInProgress();
      final wines = await this.wineRepository.getPaginated(params);
      yield WinesLoadSuccess(wines);
    } catch (_) {
      yield WinesLoadFailure();
    }
  }

  Stream<WinesState> _mapWineAddedToState(WineAdded event) async* {
    if (state is WinesLoadSuccess) {
      try {
        yield WinesLoadInProgress();
        await this.wineRepository.add(event.wine);
        final wines = await this.wineRepository.getPaginated(event.params);
        yield WinesLoadSuccess(wines);
      } catch (_) {
        yield WinesLoadFailure();
      }
    }
  }

  Stream<WinesState> _mapWineUpdatedToState(WineUpdated event) async* {
    if (state is WinesLoadSuccess) {
      try {
        yield WinesLoadInProgress();
        await this.wineRepository.update(event.wine);
        final wines = await this.wineRepository.getPaginated(event.params);
        yield WinesLoadSuccess(wines);
      } catch (_) {
        yield WinesLoadFailure();
      }
    }
  }

  Stream<WinesState> _mapWineDeletedToState(WineDeleted event) async* {
    if (state is WinesLoadSuccess) {
      try {
        yield WinesLoadInProgress();
        await this.wineRepository.remove(event.wine);
        final wines = await this.wineRepository.getPaginated(event.params);
        yield WinesLoadSuccess(wines);
      } catch (_) {
        yield WinesLoadFailure();
      }
    }
  }
}
