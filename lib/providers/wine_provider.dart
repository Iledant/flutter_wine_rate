import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/pagination.dart';
import '../models/wine.dart';
import '../repo/wine_repo.dart';

class PaginatedWinesProvider extends StateNotifier<AsyncValue<PaginatedWines>> {
  PaginatedWinesProvider() : super(AsyncValue.loading()) {
    fetch(PaginatedParams(sort: FieldSort.Name));
  }

  Future<void> fetch(PaginatedParams params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => WineRepository.getPaginated(params));
  }

  Future<void> add(Wine wine, PaginatedParams params) async {
    await WineRepository.add(wine);
    fetch(params);
  }

  Future<void> update(Wine wine, PaginatedParams params) async {
    await WineRepository.update(wine);
    fetch(params);
  }

  Future<void> remove(Wine wine, PaginatedParams params) async {
    await WineRepository.remove(wine);
    fetch(params);
  }
}

class PickWinesProvider extends StateNotifier<AsyncValue<List<Wine>>> {
  PickWinesProvider() : super(AsyncValue.loading()) {
    fetch('');
  }

  Future<void> fetch(String pattern) async {
    state = AsyncValue.loading();
    state = await AsyncValue.guard(() => WineRepository.getFirstFive(pattern));
  }
}

final paginatedWinesProvider =
    StateNotifierProvider((_) => PaginatedWinesProvider());

final pickWinesProvider = StateNotifierProvider((_) => PickWinesProvider());
