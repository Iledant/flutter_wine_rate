import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_wine_rate/providers/domain_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'common_scaffold.dart';
import 'paginated_table.dart';
import 'domain_edit_dialog.dart';
import 'models/domain.dart';
import 'repo/domain_repo.dart';

class DomainScreen extends HookWidget {
  final _scrollController = ScrollController();
  DomainScreen({Key key}) : super(key: key);

  Row _title(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    return Row(
      children: [
        Icon(Icons.home_outlined,
            size: titleStyle.fontSize, color: titleStyle.color),
        Text(' Domaines', style: titleStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = useProvider(paginatedDomainsProvider);
    final regions = useProvider(paginatedDomainsProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          _title(context),
          ItemsTableWidget<Domain, PaginatedDomains, PaginatedDomainsProvider>(
              provider: provider,
              items: regions,
              showEditDialog: showEditDomainDialog),
        ],
      ),
    );
  }
}
