enum FieldSort { IdSort, NameSort, RegionSort }

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

abstract class PaginatedRows {
  List<String> rows(int index);
  List<PaginatedHeader> headers();
  int actualLine;
  int totalLines;
}
