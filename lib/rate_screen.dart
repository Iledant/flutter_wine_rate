import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_wine_rate/providers/rate_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'screen_widget.dart';
import 'repo/rate_repo.dart';
import 'constants.dart';
import 'paginated_table.dart';
import 'delete_dialog.dart';
import 'rate_edit_dialog.dart';
import 'common_scaffold.dart';
import 'models/rate.dart';
import 'models/pagination.dart';

class RateScreen extends HookWidget {
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();

  void _addOrModify(DialogMode mode, BuildContext context, Rate rate,
      PaginatedRatesProvider provider) async {
    final result = await showEditRateDialog(context, rate, mode);
    if (result == null) return;

    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    if (mode == DialogMode.Edit)
      provider.update(result, params);
    else
      provider.add(result, params);
  }

  void _remove(Rate rate, BuildContext context, PaginatedParams params,
      PaginatedRatesProvider provider) async {
    final confirm = await showDeleteDialog(context, rate.wine);
    if (!confirm) return;
    provider.remove(rate, params);
  }

  Widget _tableWidget(BuildContext context, PaginatedRates rates,
          PaginatedRatesProvider provider) =>
      Center(
        child: PaginatedTable<Rate, PaginatedRates>(
          color: Colors.deepPurple.shade50,
          rows: rates,
          editHook: (rate) =>
              _addOrModify(DialogMode.Edit, context, rate, provider),
          addHook: () => _addOrModify(
            DialogMode.Create,
            context,
            Rate(
                id: 0,
                criticId: 0,
                critic: null,
                rate: 0.0,
                wineId: 0,
                wine: null,
                comment: null,
                classification: null,
                locationId: 0,
                location: null,
                domainId: 0,
                domain: null,
                regionId: 0,
                region: null,
                year: 0,
                published: DateTime.now()),
            provider,
          ),
          deleteHook: (rate) => _remove(
            rate,
            context,
            PaginatedParams(
              search: _nameController.text,
              firstLine: rates.actualLine,
              sort: FieldSort.Name,
            ),
            provider,
          ),
          moveHook: (i) => provider.fetch(
            PaginatedParams(
              firstLine: i,
              search: _nameController.text,
              sort: FieldSort.Name,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    final provider = useProvider(paginatedRatesProvider);
    final rates = useProvider(paginatedRatesProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                size: titleStyle.fontSize,
                color: titleStyle.color,
              ),
              Text(' Notations', style: titleStyle),
            ],
          ),
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              child: TextFormField(
                controller: _nameController,
                onChanged: (value) => provider.fetch(
                  PaginatedParams(
                    search: _nameController.text,
                    sort: FieldSort.Name,
                  ),
                ),
                decoration: const InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Recherche',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          rates.when(
            data: (rates) => _tableWidget(context, rates, provider),
            loading: () => const ProgressWidget(),
            error: (error, __) => ScreenErrorWidget(error: error),
          ),
        ],
      ),
    );
  }
}
