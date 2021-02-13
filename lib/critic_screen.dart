import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers/critic_provider.dart';
import 'common_scaffold.dart';
import 'paginated_table.dart';
import 'critic_edit_dialog.dart';
import 'models/critic.dart';
import 'repo/critic_repo.dart';

class CriticScreen extends HookWidget {
  final _scrollController = ScrollController();
  CriticScreen({Key key}) : super(key: key);

  Row _title(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    return Row(
      children: [
        Icon(Icons.account_circle,
            size: titleStyle.fontSize, color: titleStyle.color),
        Text(' Critiques', style: titleStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = useProvider(paginatedCriticsProvider);
    final regions = useProvider(paginatedCriticsProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          _title(context),
          ItemsTableWidget<Critic, PaginatedCritics, PaginatedCriticsProvider>(
              provider: provider,
              items: regions,
              showEditDialog: showEditCriticDialog),
        ],
      ),
    );
  }
}
