import 'dart:math';
import 'package:flutter/material.dart';
import 'models/pagination.dart';

class PaginatedTable<S extends EquatableWithName, T extends PaginatedRows<S>>
    extends StatefulWidget {
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
  _PaginatedTableState<S, T> createState() => _PaginatedTableState<S, T>();
}

class _PaginatedTableState<S extends EquatableWithName,
    T extends PaginatedRows<S>> extends State<PaginatedTable<S, T>> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasAction = widget.editHook != null && widget.deleteHook != null;
    final headings = widget.rows
        .tableHeaders()
        .map((e) => DataColumn(
            label: Row(
              children: [
                Text(e.label),
                if (widget.fieldSort == e.fieldSort)
                  const Icon(Icons.arrow_downward, size: 16.0)
              ],
            ),
            onSort: (_, __) => widget.sortHook?.call(e.fieldSort)))
        .toList();
    if (hasAction) headings.add(const DataColumn(label: Text('Actions')));

    final actualLine = widget.rows.actualLine;
    final totalLines = widget.rows.totalLines;
    final lastLine = min(actualLine + 9, totalLines);

    final List<DataRow> dataRows = widget.rows.lines
        .map(
          (line) => DataRow(
            cells: [
              ...line.rows().map((text) => DataCell(Text(text))).toList(),
              if (hasAction)
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _actionButton(
                          Icons.edit, () => widget.editHook.call(line)),
                      _actionButton(
                          Icons.delete, () => widget.deleteHook.call(line)),
                    ],
                  ),
                ),
            ],
          ),
        )
        .toList();

    return Card(
      color: widget.color,
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
    final nextPressed = (totalLines == lastLine)
        ? null
        : () => widget.moveHook?.call(actualLine + 10);
    final backPressed =
        (actualLine == 1) ? null : () => widget.moveHook?.call(actualLine - 10);

    return Wrap(
      spacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (widget.addHook != null)
          IconButton(
            icon: const Icon(Icons.add),
            splashRadius: 16.0,
            color: Theme.of(context).primaryColor,
            onPressed: widget.addHook,
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
