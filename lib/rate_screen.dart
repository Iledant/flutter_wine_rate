import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_wine_rate/providers/rate_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'repo/rate_repo.dart';
import 'paginated_table.dart';
import 'rate_edit_dialog.dart';
import 'common_scaffold.dart';
import 'models/rate.dart';

class RateScreen extends HookWidget {
  final _scrollController = ScrollController();

  Row _title(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    return Row(
      children: [
        Icon(Icons.stars, size: titleStyle.fontSize, color: titleStyle.color),
        Text(' Notations', style: titleStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = useProvider(paginatedRatesProvider);
    final regions = useProvider(paginatedRatesProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          _title(context),
          ItemsTableWidget<Rate, PaginatedRates, PaginatedRatesProvider>(
              provider: provider,
              items: regions,
              showEditDialog: showEditRateDialog),
        ],
      ),
    );
  }
}
