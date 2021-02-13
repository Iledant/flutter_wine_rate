import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_wine_rate/screen_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'constants.dart';
import 'delete_dialog.dart';
import 'models/pagination.dart';

class PaginatedTable<S extends EquatableWithName, T extends PaginatedRows<S>>
    extends StatelessWidget {
  final T rows;
  final void Function(S) editHook;
  final void Function(S) deleteHook;
  final void Function(int) moveHook;
  final void Function() addHook;
  final void Function(FieldSort) sortHook;
  final FieldSort fieldSort;
  final Color color;
  final void Function(PaginatedParams) changeHook;

  const PaginatedTable(
      {@required this.rows,
      this.editHook,
      this.deleteHook,
      this.moveHook,
      this.addHook,
      this.sortHook,
      this.fieldSort,
      this.changeHook,
      @required this.color,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasAction = editHook != null && deleteHook != null;
    final headings = rows
        .tableHeaders()
        .map((e) => DataColumn(
            label: Row(
              children: [
                Text(e.label),
                if (fieldSort == e.fieldSort)
                  const Icon(Icons.arrow_downward, size: 16.0)
              ],
            ),
            onSort: (_, __) => sortHook?.call(e.fieldSort)))
        .toList();
    if (hasAction) headings.add(const DataColumn(label: Text('Actions')));

    final actualLine = rows.actualLine;
    final totalLines = rows.totalLines;
    final lastLine = min(actualLine + 9, totalLines);

    final List<DataRow> dataRows = rows.lines
        .map(
          (line) => DataRow(
            cells: [
              ...line.rows().map((text) => DataCell(Text(text))).toList(),
              if (hasAction)
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _actionButton(Icons.edit, () => editHook.call(line)),
                      _actionButton(Icons.delete, () => deleteHook.call(line)),
                    ],
                  ),
                ),
            ],
          ),
        )
        .toList();

    return Card(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          DataTable(
            headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black),
            columns: headings,
            horizontalMargin: 12.0,
            columnSpacing: 12.0,
            dataRowHeight: 30.0,
            headingRowHeight: 30.0,
            showBottomBorder: true,
            rows: dataRows,
          ),
          const SizedBox(height: 8.0),
          _bottomNavigation(context, actualLine, lastLine, totalLines),
        ],
      ),
    );
  }

  IconButton _actionButton(IconData icon, void Function() onPressed) {
    return IconButton(
      iconSize: 16.0,
      splashRadius: 16.0,
      constraints: BoxConstraints(),
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }

  Wrap _bottomNavigation(
      BuildContext context, int actualLine, int lastLine, int totalLines) {
    final nextPressed =
        (totalLines == lastLine) ? null : () => moveHook?.call(actualLine + 10);
    final backPressed =
        (actualLine == 1) ? null : () => moveHook?.call(actualLine - 10);

    return Wrap(
      spacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (addHook != null)
          IconButton(
            icon: const Icon(Icons.add),
            splashRadius: 16.0,
            color: Theme.of(context).primaryColor,
            onPressed: addHook,
          ),
        Text('$actualLine-$lastLine sur $totalLines'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _arrowButton(Icons.keyboard_arrow_left, backPressed),
            _arrowButton(Icons.keyboard_arrow_right, nextPressed),
          ],
        )
      ],
    );
  }

  IconButton _arrowButton(IconData icon, void Function() onPressed) {
    return IconButton(
      icon: Icon(icon),
      splashRadius: 12.0,
      padding: const EdgeInsets.all(4.0),
      constraints: const BoxConstraints(maxWidth: 30.0),
      onPressed: onPressed,
    );
  }
}

class ItemsTableWidget<T extends EquatableWithName, S extends PaginatedRows<T>,
    P extends PaginatedNotifier<T, S>> extends StatefulHookWidget {
  final P provider;
  final AsyncValue<S> items;
  final Future<T> Function(BuildContext, T, DialogMode) showEditDialog;

  ItemsTableWidget(
      {@required this.provider,
      @required this.items,
      @required this.showEditDialog,
      Key key})
      : super(key: key);

  @override
  _ItemsTableWidgetState createState() => _ItemsTableWidgetState<T, S, P>();
}

class _ItemsTableWidgetState<T extends EquatableWithName,
        S extends PaginatedRows<T>, P extends PaginatedNotifier<T, S>>
    extends State<ItemsTableWidget<T, S, P>> {
  final _nameController = TextEditingController();

  void dispoise() {
    _nameController.dispose();
  }

  @override
  build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: TextFormField(
              controller: _nameController,
              onChanged: (value) => widget.provider.fetch(PaginatedParams(
                search: _nameController.text,
                sort: FieldSort.Name,
              )),
              decoration: const InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Recherche',
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        widget.items.when(
            loading: () => const ProgressWidget(),
            error: (error, _) => ScreenErrorWidget(error: error),
            data: (items) => _tableWidget(context, items, widget.provider)),
      ],
    );
  }

  Widget _tableWidget(BuildContext context, S items, P provider) => Center(
        child: PaginatedTable<T, S>(
          color: Colors.deepPurple.shade50,
          rows: items,
          editHook: (item) =>
              _addOrModify(DialogMode.Edit, context, item, provider),
          addHook: () =>
              _addOrModify(DialogMode.Create, context, null, provider),
          deleteHook: (item) => _remove(
              item,
              context,
              PaginatedParams(
                search: _nameController.text,
                firstLine: items.actualLine,
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

  void _addOrModify(
      DialogMode mode, BuildContext context, T item, P provider) async {
    final T result = await widget.showEditDialog(context, item, mode);
    if (result == null) return;
    final params =
        PaginatedParams(search: _nameController.text, sort: FieldSort.Name);
    if (mode == DialogMode.Edit)
      provider.update(result, params);
    else
      provider.add(result, params);
  }

  void _remove(
      T item, BuildContext context, PaginatedParams params, P provider) async {
    final confirm = await showDeleteDialog(context, item.displayName());
    if (!confirm) return;
    provider.remove(item, params);
  }
}
