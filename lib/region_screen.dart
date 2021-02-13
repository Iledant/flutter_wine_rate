import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_wine_rate/providers/region_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'common_scaffold.dart';
import 'paginated_table.dart';
import 'region_edit_dialog.dart';
import 'models/region.dart';
import 'repo/region_repo.dart';

class RegionScreen extends HookWidget {
  final _scrollController = ScrollController();

  RegionScreen({Key key}) : super(key: key);

  Row _title(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    return Row(
      children: [
        Icon(Icons.map, size: titleStyle.fontSize, color: titleStyle.color),
        Text(' Régions', style: titleStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = useProvider(paginatedRegionsProvider);
    final regions = useProvider(paginatedRegionsProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          _title(context),
          ItemsTableWidget<Region, PaginatedRegions, PaginatedRegionsProvider>(
              provider: provider,
              items: regions,
              showEditDialog: showEditRegionDialog),
        ],
      ),
    );
  }
}
