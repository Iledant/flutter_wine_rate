import 'dart:math';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import '../config.dart';
import '../models/region.dart';
import '../models/pagination.dart';

class PaginatedRegions extends PaginatedRows<Region> {
  const PaginatedRegions({int actualLine, int totalLines, List<Region> lines})
      : super(actualLine: actualLine, totalLines: totalLines, lines: lines);

  @override
  List<String> rowCells(int index) => [lines[index].name];

  @override
  List<PaginatedHeader> headers() => [PaginatedHeader('Nom', FieldSort.Name)];
}

class RegionRepository {
  const RegionRepository();

  static Future<PaginatedRegions> getPaginated(PaginatedParams params) async {
    final db = await Config().db;
    final commonQuery = " FROM region WHERE name ILIKE '%${params.search}%' ";
    final courtResults = await db.query("SELECT count(1) " + commonQuery);

    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = params.sort == FieldSort.Name ? 2 : 1;

    final results = await db.query("SELECT id,name" +
        commonQuery +
        "ORDER BY $sort LIMIT 10 OFFSET ${actualLine - 1}");

    final lines = results.map((e) => Region(id: e[0], name: e[1])).toList();

    return PaginatedRegions(
        actualLine: actualLine, totalLines: totalLines, lines: lines);
  }

  static Future<List<Region>> getFirstFive(String pattern) async {
    final db = await Config().db;
    final results = await db
        .query("""SELECT id,name FROM region WHERE name ILIKE '%$pattern%' 
          ORDER BY name LIMIT 5""");
    return results.map((e) => Region(id: e[0], name: e[1])).toList();
  }

  static Future<Region> add(Region region) async {
    final db = await Config().db;
    final results = await db.query(
        "INSERT INTO region (name) VALUES (${region.name}) RETURNING id");
    return region.copyWith(id: results[0][0]);
  }

  static Future<Region> update(Region region) async {
    final db = await Config().db;
    final results = await db.query("""UPDATE region 
    SET name=${region.name} WHERE id=${region.id} RETURNING id,name""");
    return Region(id: results[0][0], name: results[0][1]);
  }

  static Future<void> remove(Region region) async {
    final db = await Config().db;
    await db.query("DELETE FROM region WHERE id=${region.id}");
  }
}
