import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_wine_rate/providers/domain_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'common_scaffold.dart';
import 'constants.dart';
import 'delete_dialog.dart';
import 'paginated_table.dart';
import 'domain_edit_dialog.dart';
import 'models/domain.dart';
import 'models/pagination.dart';
import 'repo/domain_repo.dart';
import 'screen_widget.dart';

class DomainScreen extends HookWidget {
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  DomainScreen({Key key}) : super(key: key);

  void _addOrModify(DialogMode mode, BuildContext context, Domain domain,
      PaginatedDomainsProvider provider) async {
    final result = await showEditDomainDialog(context, domain, mode);
    if (result == null) return;

    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    if (mode == DialogMode.Edit)
      provider.update(result, params);
    else
      provider.add(result, params);
  }

  void _remove(Domain domain, BuildContext context, PaginatedParams params,
      PaginatedDomainsProvider provider) async {
    final confirm = await showDeleteDialog(context, 'le domaine ', domain.name);
    if (!confirm) return;
    provider.remove(domain, params);
  }

  Widget _tableWidget(BuildContext context, PaginatedDomains domains,
          PaginatedDomainsProvider provider) =>
      Center(
        child: PaginatedTable(
          color: Colors.deepPurple.shade50,
          rows: domains,
          editHook: (i) => _addOrModify(
              DialogMode.Edit, context, domains.lines[i], provider),
          addHook: () => _addOrModify(
              DialogMode.Create, context, Domain(id: 0, name: ''), provider),
          deleteHook: (i) => _remove(
            domains.lines[i],
            context,
            PaginatedParams(
              search: _nameController.text,
              firstLine: domains.actualLine,
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
    final provider = useProvider(paginatedDomainsProvider);
    final domains = useProvider(paginatedDomainsProvider.state);
    return CommonScaffold(
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        controller: _scrollController,
        children: [
          Row(
            children: [
              Icon(
                Icons.home_outlined,
                size: titleStyle.fontSize,
                color: titleStyle.color,
              ),
              Text(' Domaines', style: titleStyle),
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
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Recherche',
                ),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          domains.when(
            data: (domains) => _tableWidget(context, domains, provider),
            loading: () => const ProgressWidget(),
            error: (error, __) => ScreenErrorWidget(error: error),
          )
        ],
      ),
    );
  }
}
