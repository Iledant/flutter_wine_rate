import 'package:hooks_riverpod/all.dart';
import '../models/critic.dart';
import '../models/pagination.dart';
import '../repo/critic_repo.dart';

class PaginatedCriticsProvider
    extends StateNotifier<AsyncValue<PaginatedCritics>> {
  PaginatedCriticsProvider() : super(AsyncValue.loading()) {
    fetch(PaginatedParams(sort: FieldSort.Name));
  }

  Future<void> fetch(PaginatedParams params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => CriticRepository.getPaginated(params));
  }

  Future<void> add(Critic critic, PaginatedParams params) async {
    await CriticRepository.add(critic);
    fetch(params);
  }

  Future<void> update(Critic critic, PaginatedParams params) async {
    await CriticRepository.update(critic);
    fetch(params);
  }

  Future<void> remove(Critic critic, PaginatedParams params) async {
    await CriticRepository.remove(critic);
    fetch(params);
  }
}

class PickCriticsProvider extends StateNotifier<AsyncValue<List<Critic>>> {
  PickCriticsProvider() : super(AsyncValue.loading()) {
    fetch('');
  }

  Future<void> fetch(String pattern) async {
    state = AsyncValue.loading();
    state =
        await AsyncValue.guard(() => CriticRepository.getFirstFive(pattern));
  }
}

final paginatedCriticsProvider =
    StateNotifierProvider((_) => PaginatedCriticsProvider());

final pickCriticsProvider = StateNotifierProvider((_) => PickCriticsProvider());
