import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/pagination.dart';
import '../models/rate.dart';
import '../repo/rate_repo.dart';

class PaginatedRatesProvider extends PaginatedNotifier<Rate, PaginatedRates> {
  PaginatedRatesProvider() : super() {
    fetch(PaginatedParams(sort: FieldSort.Name));
  }

  Future<void> fetch(PaginatedParams params) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => RateRepository.getPaginated(params));
  }

  Future<void> add(Rate rate, PaginatedParams params) async {
    await RateRepository.add(rate);
    fetch(params);
  }

  Future<void> update(Rate rate, PaginatedParams params) async {
    await RateRepository.update(rate);
    fetch(params);
  }

  Future<void> remove(Rate rate, PaginatedParams params) async {
    await RateRepository.remove(rate);
    fetch(params);
  }
}

final paginatedRatesProvider =
    StateNotifierProvider((_) => PaginatedRatesProvider());
