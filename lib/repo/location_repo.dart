import 'dart:math';

import '../config.dart';
import '../models/location.dart';
import '../models/pagination.dart';

class PaginatedLocations extends PaginatedRows<Location> {
  const PaginatedLocations(
      {int actualLine, int totalLines, List<Location> lines})
      : super(actualLine: actualLine, totalLines: totalLines, lines: lines);

  @override
  List<String> rowCells(int index) => [lines[index].name];

  @override
  List<PaginatedHeader> tableHeaders() => Location.tableHeaders;
}

class LocationRepository {
  const LocationRepository();

  static int _getSortField(FieldSort fieldSort) {
    if (fieldSort == FieldSort.Id) return 1;
    if (fieldSort == FieldSort.Name) return 2;
    return 4;
  }

  static Future<PaginatedLocations> getPaginated(PaginatedParams params) async {
    final db = await Config().db;
    final commonQuery = """ FROM location l 
        JOIN region r ON l.region_id=r.id 
        WHERE l.name ILIKE '%${params.search}%' OR r.name ILIKE '%${params.search}%' """;
    final courtResults = await db.query("SELECT count(1) " + commonQuery);

    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = _getSortField(params.sort);

    final results = await db.query("SELECT l.id,l.name,r.id,r.name " +
        commonQuery +
        " ORDER BY $sort LIMIT 10 OFFSET ${actualLine - 1}");

    final lines = results
        .map(
            (e) => Location(id: e[0], name: e[1], regionId: e[2], region: e[3]))
        .toList();

    return PaginatedLocations(
        actualLine: actualLine, totalLines: totalLines, lines: lines);
  }

  static Future<List<Location>> getFirstFive(String pattern) async {
    final db = await Config().db;
    final results =
        await db.query("""SELECT l.id,l.name,r.id,r.name FROM location l 
          JOIN region r ON l.region_id=r.id 
          WHERE l.name ILIKE '%$pattern%' ORDER BY l.name LIMIT 5""");
    return results
        .map(
            (e) => Location(id: e[0], name: e[1], regionId: e[2], region: e[3]))
        .toList();
  }

  static Future<Location> add(Location location) async {
    final db = await Config().db;
    final results = await db.query(
        "INSERT INTO location (name,region_id) VALUES ('${location.name}',${location.regionId}) RETURNING id");
    return location.copyWith(id: results[0][0]);
  }

  static Future<Location> update(Location location) async {
    final db = await Config().db;
    await db.query("""UPDATE location 
    SET name='${location.name}', region_id=${location.regionId}
    WHERE id=${location.id}""");
    final results =
        await db.query(""" SELECT l.id,l.name,r.id,r.name FROM location l 
          JOIN region r ON l.region_id=r.id 
          WHERE l.id=${location.id}""");
    return Location(
        id: results[0][0],
        name: results[0][1],
        regionId: results[0][2],
        region: results[0][3]);
  }

  static Future<void> remove(Location location) async {
    final db = await Config().db;
    await db.query("DELETE FROM location WHERE id=${location.id}");
  }
}
