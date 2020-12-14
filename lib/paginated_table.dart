import 'dart:math';

import 'package:flutter/material.dart';

enum FieldSort { IdSort, NameSort }

class TableHeaders {
  bool hasAction;
  List<String> columns;

  TableHeaders({@required this.hasAction, @required this.columns});
}

abstract class TableRowText {
  List<String> rows(int index);
  int actualLine;
  int totalLines;
}

class PaginatedParams {
  String search;
  int firstLine;
  FieldSort sort;

  PaginatedParams(
      {this.search = '', this.firstLine = 1, this.sort = FieldSort.IdSort});
}

typedef hookFunction = void Function(int);

class PaginatedTable extends StatelessWidget {
  final TableHeaders headers;
  final TableRowText rows;
  final hookFunction editHook;
  final hookFunction deleteHook;
  final hookFunction moveHook;

  static void _defaultHook(int i) {}

  PaginatedTable(
      {@required this.headers,
      @required this.rows,
      this.editHook = _defaultHook,
      this.deleteHook = _defaultHook,
      this.moveHook = _defaultHook,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<DataColumn> dataColumns =
        headers.columns.map((e) => DataColumn(label: Text(e))).toList();
    if (headers.hasAction) {
      dataColumns.add(DataColumn(label: Text('Actions')));
    }
    final actualLine = rows.actualLine;
    final totalLines = rows.totalLines;
    final lastLine = min(actualLine + 9, totalLines);
    final backButtonDisabled = actualLine == 1;
    final nextButtonDisabled = totalLines == lastLine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DataTable(
            headingRowColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return Colors.deepPurple.shade50;
            }),
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            columns: dataColumns,
            rows: List<DataRow>.generate(
              lastLine - actualLine + 1,
              (i) => DataRow(
                cells: [
                  ...rows.rows(i).map((r) => DataCell(Text(r))).toList(),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          iconSize: 16.0,
                          splashRadius: 16.0,
                          onPressed: () => editHook(i),
                          icon: Icon(Icons.edit),
                        ),
                        IconButton(
                          splashRadius: 16.0,
                          iconSize: 16.0,
                          onPressed: () => deleteHook(i),
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )),
        SizedBox(height: 8.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$actualLine - $lastLine sur $totalLines'),
            SizedBox(width: 16.0),
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: backButtonDisabled ? Colors.grey : Colors.black,
              ),
              splashRadius: 16.0,
              onPressed: () {
                if (backButtonDisabled) {
                  return;
                }
                moveHook(actualLine - 10);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_right,
                color: nextButtonDisabled ? Colors.grey : Colors.black,
              ),
              splashRadius: 16.0,
              onPressed: () {
                if (nextButtonDisabled) {
                  return;
                }
                moveHook(actualLine + 10);
              },
            ),
          ],
        ),
      ],
    );
  }
}