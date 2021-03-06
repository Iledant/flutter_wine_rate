import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/pagination.dart';
import '../models/domain.dart';
import '../repo/domain_repo.dart';

class PaginatedDomainsProvider
    extends PaginatedNotifier<Domain, PaginatedDomains> {
  PaginatedDomainsProvider() : super() {
    fetch(PaginatedParams(sort: FieldSort.Name));
  }

  Future<void> fetch(PaginatedParams params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => DomainRepository.getPaginated(params));
  }

  Future<void> add(Domain domain, PaginatedParams params) async {
    await DomainRepository.add(domain);
    fetch(params);
  }

  Future<void> update(Domain domain, PaginatedParams params) async {
    await DomainRepository.update(domain);
    fetch(params);
  }

  Future<void> remove(Domain domain, PaginatedParams params) async {
    await DomainRepository.remove(domain);
    fetch(params);
  }
}

class PickDomainsProvider extends StateNotifier<AsyncValue<List<Domain>>> {
  PickDomainsProvider() : super(AsyncValue.data(const []));

  Future<void> fetch(String pattern) async {
    state = AsyncValue.loading();
    state =
        await AsyncValue.guard(() => DomainRepository.getFirstFive(pattern));
  }

  void clear() {
    state = AsyncValue.data(const []);
  }
}

final paginatedDomainsProvider =
    StateNotifierProvider((_) => PaginatedDomainsProvider());

final pickDomainsProvider = StateNotifierProvider((_) => PickDomainsProvider());
