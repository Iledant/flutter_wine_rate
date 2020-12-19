enum FieldSort { IdSort, NameSort }

class PaginatedParams {
  String search;
  int firstLine;
  FieldSort sort;

  PaginatedParams(
      {this.search = '', this.firstLine = 1, this.sort = FieldSort.IdSort});
}

abstract class PaginatedRows {
  List<String> rows(int index);
  int actualLine;
  int totalLines;
}
