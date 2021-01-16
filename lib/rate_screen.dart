import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repo/rate_repo.dart';
import 'bloc/rates.dart';
import 'constant.dart';
import 'paginated_table.dart';
import 'delete_dialog.dart';
// import 'rate_edit_dialog.dart';
import 'common_scaffold.dart';
import 'models/rate.dart';
import 'models/pagination.dart';

class RateScreen extends StatelessWidget {
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();

  // void _addOrModify(DialogMode mode, BuildContext context, Rate rate) async {
  //   final result = await showEditRateDialog(context, rate, mode);
  //   if (result == null) return;
  //   final params =
  //       PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
  //   switch (mode) {
  //     case DialogMode.Edit:
  //       BlocProvider.of<RatesBloc>(context).add(RateUpdated(result, params));
  //       break;
  //     default:
  //       BlocProvider.of<RatesBloc>(context).add(RateAdded(result, params));
  //       break;
  //   }
  // }

  void _remove(Rate rate, BuildContext context, PaginatedParams params) async {
    final confirm = await showDeleteDialog(context, "la notation ", rate.wine);
    if (!confirm) return;
    BlocProvider.of<RatesBloc>(context).add(RateDeleted(rate, params));
  }

  Widget _emptyWidget(BuildContext context) {
    BlocProvider.of<RatesBloc>(context).add(
      RatesLoaded(
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

  Widget _loadedWidget(BuildContext context, PaginatedRates rates) => Center(
        child: PaginatedTable(
          color: Colors.deepPurple.shade50,
          hasAction: true,
          rows: rates,
          // editHook: (i) =>
          //     _addOrModify(DialogMode.Edit, context, rates.lines[i]),
          // addHook: () => _addOrModify(
          //     DialogMode.Create,
          //     context,
          //     Rate(
          //       id: 0,
          //       name: '',
          //       regionId: 0,
          //       region: '',
          //       comment: '',
          //       classification: '',
          //       locationId: 0,
          //       location: '',
          //       domainId: 0,
          //       domain: '',
          //     )),
          deleteHook: (i) => _remove(
            rates.lines[i],
            context,
            PaginatedParams(
              search: _nameController.text,
              firstLine: rates.actualLine,
              sort: FieldSort.Name,
            ),
          ),
          moveHook: (i) => BlocProvider.of<RatesBloc>(context).add(
            RatesLoaded(
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
                Icons.stars,
                size: titleStyle.fontSize,
                color: titleStyle.color,
              ),
              Text(' Vins', style: titleStyle),
            ],
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 300),
              child: TextFormField(
                controller: _nameController,
                onChanged: (value) => BlocProvider.of<RatesBloc>(context).add(
                  RatesLoaded(
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
          BlocBuilder<RatesBloc, RatesState>(builder: (context, state) {
            if (state is RatesEmpty) return _emptyWidget(context);
            if (state is RatesLoadInProgress) return _progressWidget();
            if (state is RatesLoadFailure) return _errorWidget();
            final locations = (state as RatesLoadSuccess).rates;
            return _loadedWidget(context, locations);
          }),
        ],
      ),
    );
  }
}
