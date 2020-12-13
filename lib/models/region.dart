import 'dart:math';

import '../config.dart';
import '../paginated_table.dart';

class PaginatedRegions extends TableRowText {
  int actualLine;
  int totalLines;
  List<Region> regions;

  PaginatedRegions(this.actualLine, this.totalLines, this.regions);

  @override
  List<String> rows(int index) => [regions[index].name];
}

class Region {
  String name;
  int id;

  Region(this.id, this.name);

  Region copy() => Region(id, name);

  static Future<List<Region>> getAll(Config config) {
    return config
        .query("SELECT id,name FROM region")
        .then((results) => results.map((e) => Region(e[0], e[1])).toList());
  }

  static Future<PaginatedRegions> getPaginated(
      Config config, PaginatedParams params) async {
    final courtResults = await config.query(
        "SELECT count(1) FROM region WHERE name ILIKE @search",
        values: {"search": '%${params.search}%'});
    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = params.sort == FieldSort.NameSort ? 2 : 1;
    final regions = await config.query(
        "select id,name FROM region WHERE name ILIKE @search order by @sort LIMIT 10 OFFSET @offset",
        values: {
          "sort": sort,
          "offset": actualLine - 1,
          'search': '%${params.search}%'
        }).then((results) => results.map((e) => Region(e[0], e[1])).toList());
    return PaginatedRegions(actualLine, totalLines, regions);
  }

  static Future<List<Region>> getAllPage(Config config) {
    return config
        .query("SELECT id,name FROM region")
        .then((results) => results.map((e) => Region(e[0], e[1])).toList());
  }

  Future<void> add(Config config) async {
    final results = await config.query(
        "INSERT INTO region (name) VALUES (@name) RETURNING id",
        values: {"name": name});
    id = results[0][0];
  }

  Future<void> update(Config config) async {
    await config.query("UPDATE region SET name=@name WHERE id=@id",
        values: {"name": name, "id": id});
  }

  Future<void> remove(Config config) async {
    await config.query("DELETE FROM region WHERE id=@id", values: {"id": id});
  }
}
