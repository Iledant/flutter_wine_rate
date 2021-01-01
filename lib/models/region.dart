import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_wine_rate/models/pagination.dart';
import '../config.dart';

class PaginatedRegions extends PaginatedRows<Region> {
  int actualLine;
  int totalLines;
  List<Region> regions;

  PaginatedRegions(this.actualLine, this.totalLines, this.regions);

  @override
  List<String> rowCells(int index) => [regions[index].name];

  @override
  List<PaginatedHeader> headers() =>
      [PaginatedHeader('Nom', FieldSort.NameSort)];
}

class Region {
  String name;
  int id;

  Region({@required this.id, @required this.name});

  Region copy() => Region(id: id, name: name);

  static Future<List<Region>> getAll(Config config) {
    return config.query("SELECT id,name FROM region").then(
        (results) => results.map((e) => Region(id: e[0], name: e[1])).toList());
  }

  static Future<List<Region>> getFirstFive(Config config, String pattern) {
    return config.query(
        "SELECT id,name FROM region WHERE name ILIKE @search ORDER BY 2 LIMIT 5",
        values: {
          "search": '%$pattern%',
        }).then(
        (results) => results.map((e) => Region(id: e[0], name: e[1])).toList());
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
        }).then(
        (results) => results.map((e) => Region(id: e[0], name: e[1])).toList());
    return PaginatedRegions(actualLine, totalLines, regions);
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
