import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../repo/domain_repo.dart';
import 'pick_domains.dart';

class PickDomainsBloc extends Bloc<PickDomainsEvent, PickDomainsState> {
  final DomainRepository domainRepository;

  PickDomainsBloc({@required this.domainRepository})
      : super(PickDomainsEmpty());

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
      final domains = await this.domainRepository.getFirstFive(pattern);
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
