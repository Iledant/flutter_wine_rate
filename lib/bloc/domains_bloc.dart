import 'dart:async';
import 'package:bloc/bloc.dart';

import '../models/pagination.dart';
import '../repo/domain_repo.dart';
import 'domains.dart';

class DomainsBloc extends Bloc<DomainsEvent, DomainsState> {
  DomainsBloc() : super(DomainsEmpty());

  @override
  Stream<DomainsState> mapEventToState(DomainsEvent event) async* {
    if (event is DomainsLoaded) {
      yield* _mapDomainsLoadedToState(event.params);
    } else if (event is DomainAdded) {
      yield* _mapDomainAddedToState(event);
    } else if (event is DomainUpdated) {
      yield* _mapDomainUpdatedToState(event);
    } else if (event is DomainDeleted) {
      yield* _mapDomainDeletedToState(event);
    }
  }

  Stream<DomainsState> _mapDomainsLoadedToState(PaginatedParams params) async* {
    try {
      yield DomainsLoadInProgress();
      final domains = await DomainRepository.getPaginated(params);
      yield DomainsLoadSuccess(domains);
    } catch (_) {
      yield DomainsLoadFailure();
    }
  }

  Stream<DomainsState> _mapDomainAddedToState(DomainAdded event) async* {
    if (state is DomainsLoadSuccess) {
      try {
        yield DomainsLoadInProgress();
        await DomainRepository.add(event.domain);
        final domains = await DomainRepository.getPaginated(event.params);
        yield DomainsLoadSuccess(domains);
      } catch (_) {
        yield DomainsLoadFailure();
      }
    }
  }

  Stream<DomainsState> _mapDomainUpdatedToState(DomainUpdated event) async* {
    if (state is DomainsLoadSuccess) {
      try {
        yield DomainsLoadInProgress();
        await DomainRepository.update(event.domain);
        final domains = await DomainRepository.getPaginated(event.params);
        yield DomainsLoadSuccess(domains);
      } catch (_) {
        yield DomainsLoadFailure();
      }
    }
  }

  Stream<DomainsState> _mapDomainDeletedToState(DomainDeleted event) async* {
    if (state is DomainsLoadSuccess) {
      try {
        yield DomainsLoadInProgress();
        await DomainRepository.remove(event.domain);
        final domains = await DomainRepository.getPaginated(event.params);
        yield DomainsLoadSuccess(domains);
      } catch (_) {
        yield DomainsLoadFailure();
      }
    }
  }
}
