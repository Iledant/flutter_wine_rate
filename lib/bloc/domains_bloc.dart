import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../models/pagination.dart';
import '../repo/domain_repo.dart';
import 'domains.dart';

class DomainsBloc extends Bloc<DomainsEvent, DomainsState> {
  final DomainRepository domainRepository;

  DomainsBloc({@required this.domainRepository}) : super(DomainsEmpty());

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
      final domains = await this.domainRepository.getPaginated(params);
      yield DomainsLoadSuccess(domains);
    } catch (e) {
      print('Loaded error : $e');
      yield DomainsLoadFailure();
    }
  }

  Stream<DomainsState> _mapDomainAddedToState(DomainAdded event) async* {
    if (state is DomainsLoadSuccess) {
      try {
        yield DomainsLoadInProgress();
        await this.domainRepository.add(event.domain);
        final domains = await this.domainRepository.getPaginated(event.params);
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
        await this.domainRepository.update(event.domain);
        final domains = await this.domainRepository.getPaginated(event.params);
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
        await this.domainRepository.remove(event.domain);
        final domains = await this.domainRepository.getPaginated(event.params);
        yield DomainsLoadSuccess(domains);
      } catch (_) {
        yield DomainsLoadFailure();
      }
    }
  }
}
