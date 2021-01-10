import 'dart:math';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import '../models/rate.dart';
import '../models/pagination.dart';

class PaginatedRates extends PaginatedRows<Rate> {
  const PaginatedRates({int actualLine, int totalLines, List<Rate> lines})
      : super(actualLine: actualLine, totalLines: totalLines, lines: lines);

  @override
  List<String> rowCells(int index) => [
        lines[index].wine,
        lines[index].rate.toStringAsFixed(1),
        lines[index].year.toString(),
        lines[index].published.month.toString() +
            lines[index].published.year.toString(),
        lines[index].critic,
      ];

  @override
  List<PaginatedHeader> headers() => [
        PaginatedHeader('Vin', FieldSort.Name),
        PaginatedHeader('Note', FieldSort.Rate),
        PaginatedHeader('Millésime', FieldSort.Year),
        PaginatedHeader('Date', FieldSort.Date),
        PaginatedHeader('Critique', FieldSort.Critic),
      ];
}

class RateRepository {
  final PostgreSQLConnection db;

  const RateRepository({@required this.db});

  static int _getSortField(FieldSort fieldSort) {
    switch (fieldSort) {
      case FieldSort.Name:
        return 5;
      case FieldSort.Rate:
        return 7;
      case FieldSort.Year:
        return 8;
      case FieldSort.Date:
        return 6;
      case FieldSort.Critic:
        return 3;
      default:
        return 1;
    }
  }

  Future<PaginatedRates> getPaginated(PaginatedParams params) async {
    final commonQuery = """ FROM rate r
      JOIN critics c ON r.critics_id=c.id
      JOIN wine w ON w.id=r.wine_id
      WHERE c.name ILIKE '%%' OR w.name ILIKE '%%'""";

    final courtResults = await db.query('SELECT count(1) ' + commonQuery);
    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = _getSortField(params.sort);
    var results = await db.query(
        """SELECT r.id,c.id,c.name,w.id,w.name,r.published,r.rate,r.year """ +
            commonQuery +
            """ORDER BY $sort LIMIT 10 OFFSET ${actualLine - 1}""");
    final rates = results
        .map((e) => Rate(
              id: e[0],
              criticId: e[1],
              critic: e[2],
              wineId: e[3],
              wine: e[4],
              published: e[5],
              rate: e[6],
              year: e[7],
            ))
        .toList();
    return PaginatedRates(
        actualLine: actualLine, totalLines: totalLines, lines: rates);
  }

  Future<Rate> add(Rate rate) async {
    final results = await db
        .query("""INSERT INTO rate (critics_id,wine_id,published,rate,year)
          VALUES (@critics_id,@wine_id,@published,@rate,@year)
          RETURNING id""", substitutionValues: {
      "critics_id": rate.criticId,
      "wine_id": rate.wineId,
      "published": rate.published,
      "rate": rate.rate,
      "year": rate.year,
    });
    final id = results[0][0];
    final fields = await db.query("""SELECT c.name,w.name FROM rate r 
    JOIN critics c ON r.critics_id=c.id
    JOIN wine w ON r.wine_id=w.id
     WHERE r.id=$id """);
    return rate.copyWith(id: id, critic: fields[0][0], wine: fields[0][1]);
  }

  Future<Rate> update(Rate rate) async {
    await db.query("""UPDATE rate SET critics_id=@critics_id,wine_id=@wine_id,
        published=@published,rate=@rate,year=@year
          WHERE id=${rate.id}""", substitutionValues: {
      "critics_id": rate.criticId,
      "wine_id": rate.wineId,
      "published": rate.published,
      "rate": rate.rate,
      "year": rate.year,
    });
    final fields = await db.query("""SELECT c.name,w.name FROM rate r 
    JOIN critics c ON r.critics_id=c.id
    JOIN wine w ON r.wine_id=w.id
     WHERE r.id=${rate.id} """);
    return rate.copyWith(critic: fields[0][0], wine: fields[0][1]);
  }

  Future<void> remove(Rate rate) async {
    return await db.query("DELETE FROM rate WHERE id=@id",
        substitutionValues: {"id": rate.id});
  }
}
