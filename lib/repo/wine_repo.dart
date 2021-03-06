import 'dart:math';

import '../config.dart';
import '../models/wine.dart';
import '../models/pagination.dart';

class PaginatedWines extends PaginatedRows<Wine> {
  const PaginatedWines({int actualLine, int totalLines, List<Wine> lines})
      : super(actualLine: actualLine, totalLines: totalLines, lines: lines);

  @override
  List<String> rowCells(int index) => [
        lines[index].name,
        lines[index].classification ?? '',
        lines[index].comment ?? '',
        lines[index].domain,
        lines[index].location,
        lines[index].region
      ];

  @override
  List<PaginatedHeader> tableHeaders() => Wine.tableHeaders;
}

class WineRepository {
  const WineRepository();

  static int _getSortField(FieldSort fieldSort) {
    switch (fieldSort) {
      case FieldSort.Name:
        return 2;
      case FieldSort.Classification:
        return 3;
      case FieldSort.Comment:
        return 3;
      case FieldSort.Name:
        return 2;
      case FieldSort.Domain:
        return 6;
      case FieldSort.Location:
        return 8;
      case FieldSort.Region:
        return 10;
      default:
        return 1;
    }
  }

  static Future<PaginatedWines> getPaginated(PaginatedParams params) async {
    final db = await Config().db;
    final commonQuery = """FROM wine w
          JOIN domain d ON w.domain_id=d.id
          JOIN location l ON w.location_id=l.id
          JOIN region r ON l.region_id=r.id
          WHERE w.name ILIKE '%${params.search}%' OR r.name ILIKE '%${params.search}%'
            OR l.name ILIKE '%${params.search}%' OR d.name ILIKE '%${params.search}%'
            OR w.classification ILIKE '%${params.search}%'
            OR w.comment ILIKE '%${params.search}%' """;
    final courtResults = await db.query('SELECT count(1) ' + commonQuery);
    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = _getSortField(params.sort);
    var results =
        await db.query("""SELECT w.id,w.name,w.classification,w.comment,
          d.id,d.name,l.id,l.name,r.id,r.name """ +
            commonQuery +
            """OR w.comment ILIKE '%${params.search}%'
          ORDER BY $sort
          LIMIT 10 OFFSET ${actualLine - 1}""");
    final wines = results
        .map((e) => Wine(
              id: e[0],
              name: e[1],
              classification: e[2],
              comment: e[3],
              domainId: e[4],
              domain: e[5],
              locationId: e[6],
              location: e[7],
              regionId: e[8],
              region: e[9],
            ))
        .toList();
    return PaginatedWines(
        actualLine: actualLine, totalLines: totalLines, lines: wines);
  }

  static Future<List<Wine>> getFirstFive(String pattern) async {
    final db = await Config().db;
    final results =
        await db.query("""SELECT w.id,w.name,w.classification,w.comment,
          d.id,d.name,l.id,l.name,r.id,r.name FROM wine w
          JOIN domain d ON w.domain_id=d.id
          JOIN location l ON w.location_id=l.id
          JOIN region r ON l.region_id=r.id
          WHERE w.name ILIKE '%$pattern%' OR r.name ILIKE '%$pattern%'
            OR l.name ILIKE '%$pattern%' OR d.name ILIKE '%$pattern%'
            OR w.classification ILIKE '%$pattern%'
            OR w.comment ILIKE '%$pattern%' ORDER BY w.name LIMIT 5""");
    return results
        .map<Wine>((e) => Wine(
              id: e[0],
              name: e[1],
              classification: e[2],
              comment: e[3],
              domainId: e[4],
              domain: e[5],
              locationId: e[6],
              location: e[7],
              regionId: e[8],
              region: e[9],
            ))
        .toList();
  }

  static Future<Wine> add(Wine wine) async {
    final db = await Config().db;
    final results = await db
        .query("""INSERT INTO wine (name,classification,comment,domain_id,location_id)
          VALUES (@name,@classification,@comment,@domain_id,@location_id)
          RETURNING id""", substitutionValues: {
      "name": wine.name,
      "classification": wine.classification,
      "comment": wine.comment,
      "domain_id": wine.domainId,
      "location_id": wine.locationId,
    });
    return wine.copyWith(id: results[0][0]);
  }

  static Future<Wine> update(Wine wine) async {
    final db = await Config().db;
    await db.query("""UPDATE wine SET name=@name,classification=@classification,
          comment=@comment,domain_id=@domain_id,location_id=@location_id
          WHERE id=@id""", substitutionValues: {
      "id": wine.id,
      "name": wine.name,
      "classification": wine.classification,
      "comment": wine.comment,
      "domain_id": wine.domainId,
      "location_id": wine.locationId,
    });
    final results =
        await db.query("""SELECT w.id,w.name,w.classification,w.comment,
          d.id,d.name,l.id,l.name,r.id,r.name FROM wine w
          JOIN domain d ON w.domain_id=d.id
          JOIN location l ON w.location_id=l.id
          JOIN region r ON l.region_id=r.id WHERE id=${wine.id}""");
    return Wine(
      id: results[0][0],
      name: results[0][1],
      classification: results[0][2],
      comment: results[0][3],
      domainId: results[0][4],
      domain: results[0][5],
      locationId: results[0][6],
      location: results[0][7],
      regionId: results[0][8],
      region: results[0][9],
    );
  }

  static Future<void> remove(Wine wine) async {
    final db = await Config().db;
    return await db.query("DELETE FROM wine WHERE id=@id",
        substitutionValues: {"id": wine.id});
  }
}
