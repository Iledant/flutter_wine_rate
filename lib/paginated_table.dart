import 'dart:math';
import 'package:flutter/material.dart';
import 'models/pagination.dart';

typedef hookFunction = void Function(int);

class PaginatedTable extends StatelessWidget {
  final bool hasAction;
  final PaginatedRows rows;
  final void Function(int) editHook;
  final void Function(int) deleteHook;
  final void Function(int) moveHook;
  final void Function() addHook;
  final void Function(FieldSort) sortHook;

  PaginatedTable(
      {@required this.hasAction,
      @required this.rows,
      this.editHook,
      this.deleteHook,
      this.moveHook,
      this.addHook,
      this.sortHook,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<DataColumn> headings = rows
        .headers()
        .map((e) => DataColumn(
            label: Text(e.label),
            onSort: (index, _) => sortHook?.call(e.fieldSort)))
        .toList();
    if (hasAction) headings.add(DataColumn(label: Text('Actions')));

    final actualLine = rows.actualLine;
    final totalLines = rows.totalLines;
    final lastLine = min(actualLine + 9, totalLines);
    final backButtonDisabled = actualLine == 1;
    final nextButtonDisabled = totalLines == lastLine;

    final List<DataRow> datas = List<DataRow>.generate(
      lastLine - actualLine + 1,
      (i) => DataRow(
        cells: [
          ...rows.rows(i).map((r) => DataCell(Text(r))).toList(),
          if (hasAction)
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    iconSize: 16.0,
                    splashRadius: 16.0,
                    constraints: BoxConstraints(),
                    onPressed: () => editHook?.call(i),
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    iconSize: 16.0,
                    splashRadius: 16.0,
                    constraints: BoxConstraints(),
                    onPressed: () => deleteHook?.call(i),
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DataTable(
          headingTextStyle:
              TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          columns: headings,
          horizontalMargin: 12.0,
          columnSpacing: 12.0,
          dataRowHeight: 30.0,
          headingRowHeight: 30.0,
          showBottomBorder: true,
          rows: datas,
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (addHook != null)
              IconButton(
                onPressed: addHook,
                icon: Icon(Icons.add),
                splashRadius: 16.0,
                color: Theme.of(context).primaryColor,
              ),
            SizedBox(width: 24.0),
            Text('$actualLine - $lastLine sur $totalLines'),
            SizedBox(width: 16.0),
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: backButtonDisabled ? Colors.grey : Colors.black,
              ),
              splashRadius: 16.0,
              onPressed: () {
                if (backButtonDisabled) return;
                moveHook?.call(actualLine - 10);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_right,
                color: nextButtonDisabled ? Colors.grey : Colors.black,
              ),
              splashRadius: 16.0,
              onPressed: () {
                if (nextButtonDisabled) return;
                moveHook?.call(actualLine + 10);
              },
            ),
          ],
        ),
      ],
    );
  }
}
