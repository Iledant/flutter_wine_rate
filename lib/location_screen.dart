import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_wine_rate/providers/location_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'common_scaffold.dart';
import 'paginated_table.dart';
import 'location_edit_dialog.dart';
import 'models/location.dart';
import 'repo/location_repo.dart';

class LocationScreen extends HookWidget {
  final _scrollController = ScrollController();
  LocationScreen({Key key}) : super(key: key);

  Row _title(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    return Row(
      children: [
        Icon(Icons.home_outlined,
            size: titleStyle.fontSize, color: titleStyle.color),
        Text(' Appellations', style: titleStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = useProvider(paginatedLocationsProvider);
    final locations = useProvider(paginatedLocationsProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          _title(context),
          ItemsTableWidget<Location, PaginatedLocations,
                  PaginatedLocationsProvider>(
              provider: provider,
              items: locations,
              showEditDialog: showEditLocationDialog),
        ],
      ),
    );
  }
}
