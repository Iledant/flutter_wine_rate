import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/pagination.dart';
import '../models/region.dart';
import '../repo/region_repo.dart';

class PaginatedRegionsProvider
    extends StateNotifier<AsyncValue<PaginatedRegions>> {
  PaginatedRegionsProvider() : super(AsyncValue.loading()) {
    fetch(PaginatedParams(sort: FieldSort.Name));
  }

  Future<void> fetch(PaginatedParams params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => RegionRepository.getPaginated(params));
  }

  Future<void> add(Region region, PaginatedParams params) async {
    await RegionRepository.add(region);
    fetch(params);
  }

  Future<void> update(Region region, PaginatedParams params) async {
    await RegionRepository.update(region);
    fetch(params);
  }

  Future<void> remove(Region region, PaginatedParams params) async {
    await RegionRepository.remove(region);
    fetch(params);
  }
}

class PickRegionsProvider extends StateNotifier<AsyncValue<List<Region>>> {
  PickRegionsProvider() : super(AsyncValue.loading()) {
    fetch('');
  }

  Future<void> fetch(String pattern) async {
    state = AsyncValue.loading();
    state =
        await AsyncValue.guard(() => RegionRepository.getFirstFive(pattern));
  }
}

final paginatedRegionsProvider =
    StateNotifierProvider((_) => PaginatedRegionsProvider());

final pickRegionsProvider = StateNotifierProvider((_) => PickRegionsProvider());
