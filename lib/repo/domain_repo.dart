import 'dart:math';

import '../config.dart';
import '../models/domain.dart';
import '../models/pagination.dart';

class PaginatedDomains extends PaginatedRows<Domain> {
  const PaginatedDomains({int actualLine, int totalLines, List<Domain> lines})
      : super(actualLine: actualLine, totalLines: totalLines, lines: lines);

  @override
  List<String> rowCells(int index) => [lines[index].name];

  @override
  List<PaginatedHeader> tableHeaders() => Domain.tableHeaders;
}

class DomainRepository {
  const DomainRepository();

  static Future<PaginatedDomains> getPaginated(PaginatedParams params) async {
    final db = await Config().db;
    final commonQuery = " FROM domain WHERE name ILIKE @search ";
    final courtResults = await db.query("SELECT count(1) " + commonQuery,
        substitutionValues: {"search": '%${params.search}%'});

    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = params.sort == FieldSort.Name ? 2 : 1;

    final results = await db.query(
        "SELECT id,name" +
            commonQuery +
            "ORDER BY $sort LIMIT 10 OFFSET @offset",
        substitutionValues: {
          "offset": actualLine - 1,
          'search': '%${params.search}%'
        });

    final lines = results.map((e) => Domain(id: e[0], name: e[1])).toList();

    return PaginatedDomains(
        actualLine: actualLine, totalLines: totalLines, lines: lines);
  }

  static Future<List<Domain>> getFirstFive(String pattern) async {
    final db = await Config().db;
    final results = await db
        .query("""SELECT id,name FROM domain WHERE name ILIKE '%$pattern%' 
          ORDER BY name LIMIT 5""");
    return results.map((e) => Domain(id: e[0], name: e[1])).toList();
  }

  static Future<Domain> add(Domain domain) async {
    final db = await Config().db;
    final results = await db.query(
        "INSERT INTO domain (name) VALUES (@name) RETURNING id",
        substitutionValues: {"name": domain.name});
    return domain.copyWith(id: results[0][0]);
  }

  static Future<Domain> update(Domain domain) async {
    final db = await Config().db;
    final results = await db.query("""UPDATE domain SET name=@name WHERE id=@id 
    RETURNING id,name""",
        substitutionValues: {"name": domain.name, "id": domain.id});
    return Domain(id: results[0][0], name: results[0][1]);
  }

  static Future<void> remove(Domain domain) async {
    final db = await Config().db;
    await db.query("DELETE FROM domain WHERE id=@id",
        substitutionValues: {"id": domain.id});
  }
}
