import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_wine_rate/models/pagination.dart';
import '../config.dart';

class PaginatedLocations extends PaginatedRows<Location> {
  int actualLine;
  int totalLines;
  List<Location> locations;

  PaginatedLocations(this.actualLine, this.totalLines, this.locations);

  @override
  List<String> rowCells(int index) =>
      [locations[index].name, locations[index].region];

  @override
  List<PaginatedHeader> headers() => [
        PaginatedHeader('Nom', FieldSort.Name),
        PaginatedHeader('Région', FieldSort.Region)
      ];
}

class Location {
  String name;
  String region;
  int regionId;
  int id;

  Location({
    @required this.id,
    @required this.name,
    this.regionId,
    this.region,
  });

  Location copy() => Location(
        id: id,
        name: name,
        regionId: regionId,
        region: region,
      );

  static Future<List<Location>> getAll(Config config) {
    return config.query("""SELECT l.id,l.name,r.id,r.name FROM location l 
      JOIN region r ON l.region_id=r.id""").then((results) => results
        .map((e) => Location(
              id: e[0],
              name: e[1],
              regionId: e[2],
              region: e[3],
            ))
        .toList());
  }

  static int _getSortField(FieldSort fieldSort) {
    if (fieldSort == FieldSort.Id) return 1;
    if (fieldSort == FieldSort.Name) return 2;
    return 4;
  }

  static Future<PaginatedLocations> getPaginated(
      Config config, PaginatedParams params) async {
    final courtResults = await config.query("""SELECT count(1) FROM location l 
        JOIN region r ON l.region_id=r.id 
        WHERE l.name ILIKE @search OR r.name ILIKE @search""",
        values: {"search": '%${params.search}%'});
    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = _getSortField(params.sort);
    var results =
        await config.query("""SELECT l.id,l.name,r.id,r.name FROM location l
          JOIN region r ON l.region_id=r.id 
          WHERE l.name ILIKE '%${params.search}%' OR r.name ILIKE '%${params.search}%'
          ORDER BY $sort
          LIMIT 10 OFFSET ${actualLine - 1}""");
    final locations = results
        .map((e) => Location(
              id: e[0],
              name: e[1],
              regionId: e[2],
              region: e[3],
            ))
        .toList();
    return PaginatedLocations(actualLine, totalLines, locations);
  }

  Future<void> add(Config config) async {
    final results = await config.query(
        "INSERT INTO location (name,region_id) VALUES (@name,@region_id) RETURNING id",
        values: {"name": name, "region_id": regionId});
    id = results[0][0];
  }

  Future<void> update(Config config) async {
    await config.query(
        "UPDATE location SET name=@name,region_id=@region_id WHERE id=@id",
        values: {"name": name, "region_id": regionId, "id": id});
  }

  Future<void> remove(Config config) async {
    await config.query("DELETE FROM location WHERE id=@id", values: {"id": id});
  }
}
