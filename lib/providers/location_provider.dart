import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/pagination.dart';
import '../models/location.dart';
import '../repo/location_repo.dart';

class PaginatedLocationsProvider
    extends StateNotifier<AsyncValue<PaginatedLocations>> {
  PaginatedLocationsProvider() : super(AsyncValue.loading()) {
    fetch(PaginatedParams(sort: FieldSort.Name));
  }

  Future<void> fetch(PaginatedParams params) async {
    state = const AsyncValue.loading();
    state =
        await AsyncValue.guard(() => LocationRepository.getPaginated(params));
  }

  Future<void> add(Location location, PaginatedParams params) async {
    await LocationRepository.add(location);
    fetch(params);
  }

  Future<void> update(Location location, PaginatedParams params) async {
    await LocationRepository.update(location);
    fetch(params);
  }

  Future<void> remove(Location location, PaginatedParams params) async {
    await LocationRepository.remove(location);
    fetch(params);
  }
}

class PickLocationsProvider extends StateNotifier<AsyncValue<List<Location>>> {
  PickLocationsProvider() : super(AsyncValue.loading()) {
    fetch('');
  }

  Future<void> fetch(String pattern) async {
    state = AsyncValue.loading();
    state =
        await AsyncValue.guard(() => LocationRepository.getFirstFive(pattern));
  }
}

final paginatedLocationsProvider =
    StateNotifierProvider((_) => PaginatedLocationsProvider());

final pickLocationsProvider =
    StateNotifierProvider((_) => PickLocationsProvider());
