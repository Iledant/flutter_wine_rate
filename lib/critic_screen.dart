import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/critics.dart';
import 'common_scaffold.dart';
import 'constant.dart';
import 'delete_dialog.dart';
import 'paginated_table.dart';
import 'critic_edit_dialog.dart';
import 'models/critic.dart';
import 'models/pagination.dart';
import 'repo/critic_repo.dart';

class CriticScreen extends StatelessWidget {
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  CriticScreen({Key key}) : super(key: key);

  void _addOrModify(
      DialogMode mode, BuildContext context, Critic critic) async {
    final result = await showEditCriticDialog(context, critic, mode);
    if (result == null) return;
    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    switch (mode) {
      case DialogMode.Edit:
        BlocProvider.of<CriticsBloc>(context)
            .add(CriticUpdated(result, params));
        break;
      default:
        BlocProvider.of<CriticsBloc>(context).add(CriticAdded(result, params));
        break;
    }
  }

  void _remove(
      Critic critic, BuildContext context, PaginatedParams params) async {
    final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            DeleteDialog(objectKind: 'le critique ', objectName: critic.name));
    if (!confirm) return;
    BlocProvider.of<CriticsBloc>(context).add(CriticDeleted(critic, params));
  }

  Widget _emptyWidget(BuildContext context) {
    BlocProvider.of<CriticsBloc>(context).add(
      CriticsLoaded(
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

  Widget _loadedWidget(BuildContext context, PaginatedCritics critics) =>
      Center(
        child: PaginatedTable(
          color: Colors.deepPurple.shade50,
          hasAction: true,
          rows: critics,
          editHook: (i) =>
              _addOrModify(DialogMode.Edit, context, critics.lines[i]),
          addHook: () =>
              _addOrModify(DialogMode.Create, context, Critic(id: 0, name: '')),
          deleteHook: (i) => _remove(
            critics.lines[i],
            context,
            PaginatedParams(
              search: _nameController.text,
              firstLine: critics.actualLine,
              sort: FieldSort.Name,
            ),
          ),
          moveHook: (i) => BlocProvider.of<CriticsBloc>(context).add(
            CriticsLoaded(
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
                Icons.account_circle,
                size: titleStyle.fontSize,
                color: titleStyle.color,
              ),
              Text(' Critiques', style: titleStyle),
            ],
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: TextFormField(
                controller: _nameController,
                onChanged: (value) => BlocProvider.of<CriticsBloc>(context).add(
                  CriticsLoaded(
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
          BlocBuilder<CriticsBloc, CriticsState>(builder: (context, state) {
            if (state is CriticsEmpty) return _emptyWidget(context);
            if (state is CriticsLoadInProgress) return _progressWidget();
            if (state is CriticsLoadFailure) return _errorWidget();
            final critics = (state as CriticsLoadSuccess).critics;
            return _loadedWidget(context, critics);
          }),
        ],
      ),
    );
  }
}
