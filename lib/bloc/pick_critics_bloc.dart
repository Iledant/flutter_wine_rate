import 'dart:async';
import 'package:bloc/bloc.dart';

import '../repo/critic_repo.dart';
import 'pick_critics.dart';

class PickCriticsBloc extends Bloc<PickCriticsEvent, PickCriticsState> {
  PickCriticsBloc() : super(PickCriticsEmpty());

  @override
  Stream<PickCriticsState> mapEventToState(PickCriticsEvent event) async* {
    if (event is PickCriticsLoaded) {
      yield* _mapPickCriticsLoadedToState(event.pattern);
    } else if (event is PickCriticsClear) {
      yield* _mapPickCriticsEmptyToState();
    }
  }

  Stream<PickCriticsState> _mapPickCriticsLoadedToState(String pattern) async* {
    try {
      yield PickCriticsLoadInProgress();
      final critics = await CriticRepository.getFirstFive(pattern);
      yield PickCriticsLoadSuccess(critics);
    } catch (_) {
      yield PickCriticsLoadFailure();
    }
  }

  Stream<PickCriticsState> _mapPickCriticsEmptyToState() async* {
    try {
      yield PickCriticsLoadSuccess(const []);
    } catch (_) {
      yield PickCriticsLoadFailure();
    }
  }
}
