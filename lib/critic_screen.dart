import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/critics.dart';
import 'common_scaffold.dart';
import 'constant.dart';
import 'paginated_table.dart';
import 'critic_edit_dialog.dart';
import 'models/critic.dart';
import 'models/pagination.dart';

class CriticScreen extends StatelessWidget {
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  CriticScreen({Key key}) : super(key: key);

  void _editCritic(DialogMode mode, BuildContext context, Critic critic) async {
    final result = await showDialog<Critic>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CriticEditDialog(mode, critic),
    );
    if (result == null) return;
    switch (mode) {
      case DialogMode.Edit:
        BlocProvider.of<CriticsBloc>(context).add(CriticUpdated(
            result, PaginatedParams(search: _nameController.text)));
        break;
      default:
        BlocProvider.of<CriticsBloc>(context).add(
            CriticAdded(result, PaginatedParams(search: _nameController.text)));
        break;
    }
  }

  void _removeCritic(Critic critic, PaginatedParams params) async {}

  Widget _progressIndicator() =>
      CommonScaffold(body: Center(child: CircularProgressIndicator()));

  Widget _errorWidget() => CommonScaffold(
        body: Center(
          child: Container(
            color: Colors.red,
            padding: EdgeInsets.all(8.0),
            child: Text('Erreur de chargement'),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    return BlocBuilder<CriticsBloc, CriticsState>(builder: (context, state) {
      if (state is CriticsLoadInProgress) return _progressIndicator();
      if (state is CriticsLoadFailure) return _errorWidget();
      final critics = (state as CriticsLoadSuccess).critics;
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
                  onChanged: (value) =>
                      BlocProvider.of<CriticsBloc>(context).add(
                    CriticsLoaded(
                      PaginatedParams(
                          search: _nameController.text, sort: FieldSort.Name),
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
            Center(
              child: PaginatedTable(
                color: Colors.deepPurple.shade50,
                hasAction: true,
                rows: critics,
                editHook: (i) =>
                    _editCritic(DialogMode.Edit, context, critics.lines[i]),
                addHook: () => _editCritic(
                    DialogMode.Create, context, Critic(id: 0, name: '')),
                deleteHook: (i) => _removeCritic(
                  critics.lines[i],
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
            ),
          ],
        ),
      );
    });
  }
}
