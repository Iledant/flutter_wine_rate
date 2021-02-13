import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers/wine_provider.dart';
import 'repo/wine_repo.dart';
import 'paginated_table.dart';
import 'wine_edit_dialog.dart';
import 'common_scaffold.dart';
import 'models/wine.dart';

class WineScreen extends HookWidget {
  final _scrollController = ScrollController();

  Row _title(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    return Row(
      children: [
        Icon(Icons.wine_bar_outlined,
            size: titleStyle.fontSize, color: titleStyle.color),
        Text(' Vins', style: titleStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = useProvider(paginatedWinesProvider);
    final regions = useProvider(paginatedWinesProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          _title(context),
          ItemsTableWidget<Wine, PaginatedWines, PaginatedWinesProvider>(
              provider: provider,
              items: regions,
              showEditDialog: showEditWineDialog),
        ],
      ),
    );
  }
}
