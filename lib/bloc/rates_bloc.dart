import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import '../models/pagination.dart';
import '../repo/rate_repo.dart';
import 'rates.dart';

class RatesBloc extends Bloc<RatesEvent, RatesState> {
  RatesBloc() : super(RatesEmpty());

  @override
  Stream<RatesState> mapEventToState(RatesEvent event) async* {
    if (event is RatesLoaded) {
      yield* _mapRatesLoadedToState(event.params);
    } else if (event is RateAdded) {
      yield* _mapRateAddedToState(event);
    } else if (event is RateUpdated) {
      yield* _mapRateUpdatedToState(event);
    } else if (event is RateDeleted) {
      yield* _mapRateDeletedToState(event);
    }
  }

  Stream<RatesState> _mapRatesLoadedToState(PaginatedParams params) async* {
    try {
      yield RatesLoadInProgress();
      final rates = await RateRepository.getPaginated(params);
      yield RatesLoadSuccess(rates);
    } catch (_) {
      yield RatesLoadFailure();
    }
  }

  Stream<RatesState> _mapRateAddedToState(RateAdded event) async* {
    if (state is RatesLoadSuccess) {
      try {
        yield RatesLoadInProgress();
        await RateRepository.add(event.rate);
        final rates = await RateRepository.getPaginated(event.params);
        yield RatesLoadSuccess(rates);
      } catch (e) {
        debugPrint('RateAdd $e');
        yield RatesLoadFailure();
      }
    }
  }

  Stream<RatesState> _mapRateUpdatedToState(RateUpdated event) async* {
    if (state is RatesLoadSuccess) {
      try {
        yield RatesLoadInProgress();
        await RateRepository.update(event.rate);
        final rates = await RateRepository.getPaginated(event.params);
        yield RatesLoadSuccess(rates);
      } catch (_) {
        yield RatesLoadFailure();
      }
    }
  }

  Stream<RatesState> _mapRateDeletedToState(RateDeleted event) async* {
    if (state is RatesLoadSuccess) {
      try {
        yield RatesLoadInProgress();
        await RateRepository.remove(event.rate);
        final rates = await RateRepository.getPaginated(event.params);
        yield RatesLoadSuccess(rates);
      } catch (_) {
        yield RatesLoadFailure();
      }
    }
  }
}
