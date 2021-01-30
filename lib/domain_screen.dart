import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/domains.dart';
import 'common_scaffold.dart';
import 'constants.dart';
import 'delete_dialog.dart';
import 'paginated_table.dart';
import 'domain_edit_dialog.dart';
import 'models/domain.dart';
import 'models/pagination.dart';
import 'repo/domain_repo.dart';

class DomainScreen extends StatelessWidget {
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  DomainScreen({Key key}) : super(key: key);

  void _addOrModify(
      DialogMode mode, BuildContext context, Domain domain) async {
    final result = await showEditDomainDialog(context, domain, mode);
    if (result == null) return;
    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    switch (mode) {
      case DialogMode.Edit:
        BlocProvider.of<DomainsBloc>(context)
            .add(DomainUpdated(result, params));
        break;
      default:
        BlocProvider.of<DomainsBloc>(context).add(DomainAdded(result, params));
        break;
    }
  }

  void _remove(
      Domain domain, BuildContext context, PaginatedParams params) async {
    final confirm = await showDeleteDialog(context, 'le domaine ', domain.name);
    if (!confirm) return;
    BlocProvider.of<DomainsBloc>(context).add(DomainDeleted(domain, params));
  }

  Widget _emptyWidget(BuildContext context) {
    BlocProvider.of<DomainsBloc>(context).add(
      DomainsLoaded(
        PaginatedParams(
          search: _nameController.text,
          sort: FieldSort.Name,
        ),
      ),
    );
    return SizedBox.shrink();
  }

  Widget _progressWidget() =>
      Center(child: CircularProgressIndicator(value: null));

  Widget _errorWidget() => Center(
        child: Container(
          color: Colors.red,
          padding: EdgeInsets.all(8.0),
          child: Text('Erreur de chargement'),
        ),
      );

  Widget _loadedWidget(BuildContext context, PaginatedDomains domains) =>
      Center(
        child: PaginatedTable(
          color: Colors.deepPurple.shade50,
          rows: domains,
          editHook: (i) =>
              _addOrModify(DialogMode.Edit, context, domains.lines[i]),
          addHook: () =>
              _addOrModify(DialogMode.Create, context, Domain(id: 0, name: '')),
          deleteHook: (i) => _remove(
            domains.lines[i],
            context,
            PaginatedParams(
              search: _nameController.text,
              firstLine: domains.actualLine,
              sort: FieldSort.Name,
            ),
          ),
          moveHook: (i) => BlocProvider.of<DomainsBloc>(context).add(
            DomainsLoaded(
              PaginatedParams(
                firstLine: i,
                search: _nameController.text,
                sort: FieldSort.Name,
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    return CommonScaffold(
      body: ListView(
        padding: EdgeInsets.all(8.0),
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
              constraints: BoxConstraints(maxWidth: 300),
              child: TextFormField(
                controller: _nameController,
                onChanged: (value) => BlocProvider.of<DomainsBloc>(context).add(
                  DomainsLoaded(
                    PaginatedParams(
                      search: _nameController.text,
                      sort: FieldSort.Name,
                    ),
                  ),
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Recherche',
                ),
              ),
            ),
          ),
          SizedBox(height: 10.0),
          BlocBuilder<DomainsBloc, DomainsState>(builder: (context, state) {
            if (state is DomainsEmpty) return _emptyWidget(context);
            if (state is DomainsLoadInProgress) return _progressWidget();
            if (state is DomainsLoadFailure) return _errorWidget();
            final domains = (state as DomainsLoadSuccess).domains;
            return _loadedWidget(context, domains);
          }),
        ],
      ),
    );
  }
}
