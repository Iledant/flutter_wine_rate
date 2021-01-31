import 'dart:math';
import 'package:flutter/material.dart';
import 'models/pagination.dart';

class PaginatedTable extends StatelessWidget {
  final PaginatedRows rows;
  final void Function(int) editHook;
  final void Function(int) deleteHook;
  final void Function(int) moveHook;
  final void Function() addHook;
  final void Function(FieldSort) sortHook;
  final FieldSort fieldSort;
  final Color color;

  PaginatedTable(
      {@required this.rows,
      this.editHook,
      this.deleteHook,
      this.moveHook,
      this.addHook,
      this.sortHook,
      this.fieldSort,
      @required this.color,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasAction = editHook != null && deleteHook != null;
    final headings = rows
        .headers()
        .map((e) => DataColumn(
            label: Row(children: [
              Text(e.label),
              if (fieldSort == e.fieldSort)
                const Icon(Icons.arrow_downward, size: 16.0)
            ]),
            onSort: (_, __) => sortHook?.call(e.fieldSort)))
        .toList();
    if (hasAction) headings.add(const DataColumn(label: Text('Actions')));

    final actualLine = rows.actualLine;
    final totalLines = rows.totalLines;
    final lastLine = min(actualLine + 9, totalLines);

    final List<DataRow> datas = List<DataRow>.generate(
      lastLine - actualLine + 1,
      (i) => DataRow(
        cells: [
          ...rows.rowCells(i).map((r) => DataCell(Text(r))).toList(),
          if (hasAction)
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionButton(Icons.edit, () => editHook?.call(i)),
                  _actionButton(Icons.delete, () => deleteHook?.call(i)),
                ],
              ),
            ),
        ],
      ),
    );

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
            rows: datas,
          ),
          const SizedBox(height: 8.0),
          _bottomNavigation(
              context, actualLine, lastLine, totalLines, moveHook),
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

  Wrap _bottomNavigation(BuildContext context, int actualLine, int lastLine,
      int totalLines, void Function(int) moveHook) {
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
