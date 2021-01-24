import 'dart:async';
import 'package:bloc/bloc.dart';

import '../repo/domain_repo.dart';
import 'pick_domains.dart';

class PickDomainsBloc extends Bloc<PickDomainsEvent, PickDomainsState> {
  PickDomainsBloc() : super(PickDomainsEmpty());

  @override
  Stream<PickDomainsState> mapEventToState(PickDomainsEvent event) async* {
    if (event is PickDomainsLoaded) {
      yield* _mapPickDomainsLoadedToState(event.pattern);
    } else if (event is PickDomainsClear) {
      yield* _mapPickDomainsEmptyToState();
    }
  }

  Stream<PickDomainsState> _mapPickDomainsLoadedToState(String pattern) async* {
    try {
      yield PickDomainsLoadInProgress();
      final domains = await DomainRepository.getFirstFive(pattern);
      yield PickDomainsLoadSuccess(domains);
    } catch (_) {
      yield PickDomainsLoadFailure();
    }
  }

  Stream<PickDomainsState> _mapPickDomainsEmptyToState() async* {
    try {
      yield PickDomainsLoadSuccess(const []);
    } catch (_) {
      yield PickDomainsLoadFailure();
    }
  }
}
