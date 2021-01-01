import 'package:flutter/cupertino.dart';

enum FieldSort {
  IdSort,
  NameSort,
  RegionSort,
  LocationSort,
  DomainSort,
  ClassificationSort,
  CommentSort,
}

class PaginatedParams {
  String search;
  int firstLine;
  FieldSort sort;

  PaginatedParams(
      {this.search = '', this.firstLine = 1, this.sort = FieldSort.IdSort});
}

class PaginatedHeader {
  String label;
  FieldSort fieldSort;

  PaginatedHeader(this.label, this.fieldSort);
}

abstract class PaginatedRows<T> {
  final int actualLine;
  final int totalLines;
  final List<T> lines;

  List<String> rowCells(int index);
  List<PaginatedHeader> headers();

  const PaginatedRows(
      {@required this.actualLine,
      @required this.totalLines,
      @required this.lines});
}
