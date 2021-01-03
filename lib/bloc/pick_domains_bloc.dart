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
    }
  }

  Stream<PickDomainsState> _mapPickDomainsLoadedToState(String pattern) async* {
    try {
      yield PickDomainsLoadInProgress();
      final domains = await this.domainRepository.getFirstFive(pattern);
      yield PickDomainsLoadSuccess(domains);
    } catch (e) {
      print('Loaded error : $e');
      yield PickDomainsLoadFailure();
    }
  }
}
