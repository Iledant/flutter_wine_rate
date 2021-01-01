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
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  CriticScreen({Key key}) : super(key: key);

  void editCritic(DialogMode mode, BuildContext context, Critic critic) async {
    final result = await showDialog<Critic>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CriticEditDialog(mode, critic),
    );
    if (result == null) return;
    switch (mode) {
      case DialogMode.Edit:
        BlocProvider.of<CriticsBloc>(context).add(
            CriticAdded(critic, PaginatedParams(search: _controller.text)));
        break;
      default:
        BlocProvider.of<CriticsBloc>(context).add(
            CriticUpdated(critic, PaginatedParams(search: _controller.text)));
        break;
    }
  }

  void removeCritic(Critic critic, PaginatedParams params) async {}

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headline4;
    return BlocBuilder<CriticsBloc, CriticsState>(builder: (context, state) {
      if (state is CriticsLoadInProgress) {
        return CommonScaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (state is CriticsLoadFailure) {
        return CommonScaffold(
          body: Center(
            child: Container(
              color: Colors.red,
              padding: EdgeInsets.all(8.0),
              child: Text('Erreur de chargement'),
            ),
          ),
        );
      }
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
                  controller: _controller,
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
                    editCritic(DialogMode.Edit, context, critics.lines[i]),
                deleteHook: (i) => removeCritic(
                  critics.lines[i],
                  PaginatedParams(
                    search: _controller.text,
                    firstLine: critics.actualLine,
                    sort: FieldSort.NameSort,
                  ),
                ),
                moveHook: (i) {
                  BlocProvider.of<CriticsBloc>(context).add(
                    CriticsLoadSuccessed(
                      PaginatedParams(
                        firstLine: i,
                        search: _controller.text,
                        sort: FieldSort.NameSort,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
