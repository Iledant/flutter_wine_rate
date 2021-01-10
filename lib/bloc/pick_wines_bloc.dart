import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../repo/wine_repo.dart';
import 'pick_wines.dart';

class PickWinesBloc extends Bloc<PickWinesEvent, PickWinesState> {
  final WineRepository wineRepository;

  PickWinesBloc({@required this.wineRepository}) : super(PickWinesEmpty());

  @override
  Stream<PickWinesState> mapEventToState(PickWinesEvent event) async* {
    if (event is PickWinesLoaded) {
      yield* _mapPickWinesLoadedToState(event.pattern);
    } else if (event is PickWinesClear) {
      yield* _mapPickWinesEmptyToState();
    }
  }

  Stream<PickWinesState> _mapPickWinesLoadedToState(String pattern) async* {
    try {
      yield PickWinesLoadInProgress();
      final wines = await this.wineRepository.getFirstFive(pattern);
      yield PickWinesLoadSuccess(wines);
    } catch (_) {
      yield PickWinesLoadFailure();
    }
  }

  Stream<PickWinesState> _mapPickWinesEmptyToState() async* {
    try {
      yield PickWinesLoadSuccess(const []);
    } catch (_) {
      yield PickWinesLoadFailure();
    }
  }
}
