import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'providers/critic_provider.dart';
import 'common_scaffold.dart';
import 'constants.dart';
import 'delete_dialog.dart';
import 'paginated_table.dart';
import 'critic_edit_dialog.dart';
import 'models/critic.dart';
import 'models/pagination.dart';
import 'repo/critic_repo.dart';
import 'screen_widget.dart';

class CriticScreen extends HookWidget {
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  CriticScreen({Key key}) : super(key: key);

  void _addOrModify(DialogMode mode, BuildContext context, Critic critic,
      PaginatedCriticsProvider provider) async {
    final result = await showEditCriticDialog(context, critic, mode);
    if (result == null) return;

    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    if (mode == DialogMode.Edit)
      provider.update(result, params);
    else
      provider.add(result, params);
  }

  void _remove(Critic critic, BuildContext context, PaginatedParams params,
      PaginatedCriticsProvider provider) async {
    final confirm =
        await showDeleteDialog(context, 'le critique ', critic.name);
    if (!confirm) return;
    provider.remove(critic, params);
  }

  Widget _tableWidget(BuildContext context, PaginatedCritics critics,
          PaginatedCriticsProvider provider) =>
      Center(
        child: PaginatedTable(
          color: Colors.deepPurple.shade50,
          rows: critics,
          editHook: (i) => _addOrModify(
              DialogMode.Edit, context, critics.lines[i], provider),
          addHook: () => _addOrModify(
              DialogMode.Create, context, Critic(id: 0, name: ''), provider),
          deleteHook: (i) => _remove(
              critics.lines[i],
              context,
              PaginatedParams(
                search: _nameController.text,
                firstLine: critics.actualLine,
                sort: FieldSort.Name,
              ),
              provider),
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
    final provider = useProvider(paginatedCriticsProvider);
    final critics = useProvider(paginatedCriticsProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle,
                size: titleStyle.fontSize,
                color: titleStyle.color,
              ),
              Text(' Critiques', style: titleStyle),
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
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Recherche',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          critics.when(
            data: (critics) => _tableWidget(context, critics, provider),
            loading: () => const ProgressWidget(),
            error: (error, __) => ScreenErrorWidget(error: error),
          ),
        ],
      ),
    );
  }
}
