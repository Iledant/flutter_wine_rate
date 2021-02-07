import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum FieldSort {
  Id,
  Name,
  Region,
  Location,
  Domain,
  Classification,
  Comment,
  Rate,
  Year,
  Date,
  Critic
}

class PaginatedParams {
  final String search;
  final int firstLine;
  final FieldSort sort;

  const PaginatedParams(
      {this.search = '', this.firstLine = 1, this.sort = FieldSort.Id});
}

class PaginatedHeader {
  final String label;
  final FieldSort fieldSort;

  const PaginatedHeader(this.label, this.fieldSort);
}

abstract class TableHeaders {
  List<PaginatedHeader> tableHeaders();

  const TableHeaders();
}

abstract class PaginatedRows<T> extends TableHeaders {
  final int actualLine;
  final int totalLines;
  final List<T> lines;

  List<String> rowCells(int index);

  const PaginatedRows(
      {@required this.actualLine,
      @required this.totalLines,
      @required this.lines});
}

abstract class EquatableWithName extends Equatable {
  String displayName();
  List<String> rows();

  const EquatableWithName() : super();
}
