import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:postgres/postgres.dart';

import '../models/rate.dart';
import '../models/pagination.dart';

class PaginatedRates extends PaginatedRows<Rate> {
  const PaginatedRates({int actualLine, int totalLines, List<Rate> lines})
      : super(actualLine: actualLine, totalLines: totalLines, lines: lines);

  @override
  List<String> rowCells(int index) {
    final dateFormatter = new DateFormat('MM/yy');

    return [
      lines[index].wine,
      lines[index].location,
      lines[index].domain,
      lines[index].rate.toStringAsFixed(1),
      lines[index].year.toString(),
      dateFormatter.format(lines[index].published),
      lines[index].critic,
    ];
  }

  @override
  List<PaginatedHeader> headers() => [
        PaginatedHeader('Vin', FieldSort.Name),
        PaginatedHeader('Appellation', FieldSort.Location),
        PaginatedHeader('Domaine', FieldSort.Domain),
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
      case FieldSort.Location:
        return 7;
      case FieldSort.Rate:
        return 9;
      case FieldSort.Year:
        return 10;
      case FieldSort.Domain:
        return 12;
      case FieldSort.Region:
        return 14;
      case FieldSort.Date:
        return 8;
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
      JOIN location l ON w.location_id=l.id
      JOIN domain d ON w.domain_id=d.id
      JOIN region reg ON l.region_id=reg.id
      WHERE c.name ILIKE '%${params.search}%' 
        OR w.name ILIKE '%${params.search}%'
        OR l.name ILIKE '%${params.search}%'
        OR d.name ILIKE '%${params.search}%'
        OR reg.name ILIKE '%${params.search}%'""";

    final courtResults = await db.query('SELECT count(1) ' + commonQuery);
    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = _getSortField(params.sort);
    var results = await db.query(
        """SELECT r.id,c.id,c.name,w.id,w.name,l.id,l.name,r.published,r.rate,
        r.year,d.id,d.name,reg.id,reg.name,w.comment,w.classification """ +
            commonQuery +
            """ORDER BY $sort LIMIT 10 OFFSET ${actualLine - 1}""");
    final rates = results
        .map((e) => Rate(
              id: e[0],
              criticId: e[1],
              critic: e[2],
              wineId: e[3],
              wine: e[4],
              locationId: e[5],
              location: e[6],
              published: e[7],
              rate: e[8],
              year: e[9],
              domainId: e[10],
              domain: e[11],
              regionId: e[12],
              region: e[13],
              comment: e[14],
              classification: e[15],
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
    final fields = await db
        .query("""SELECT c.name,w.name,l.id,l.name,d.id,d.name,reg.id,reg.name,
        w.comment,w.classification FROM rate r 
    JOIN critics c ON r.critics_id=c.id
    JOIN wine w ON r.wine_id=w.id
    JOIN location l ON w.location_id=l.id
    JOIN domain d ON w.domain_id=d.id
    JOIN region reg ON l.region_id=reg.id
     WHERE r.id=$id """);
    final result = fields[0];
    return rate.copyWith(
      id: id,
      critic: result[0],
      wine: result[1],
      locationId: result[2],
      location: result[3],
      domainId: result[4],
      domain: result[5],
      regionId: result[6],
      region: result[7],
      comment: result[8],
      classification: result[9],
    );
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
    final fields = await db
        .query("""SELECT c.name,w.name,l.id,l.name,d.id,d.name,reg.id,reg.name,
        w.comment,w.classification FROM rate r 
    JOIN critics c ON r.critics_id=c.id
    JOIN wine w ON r.wine_id=w.id
    JOIN location l ON w.location_id=l.id
    JOIN domain d ON w.domain_id=d.id
    JOIN region reg ON l.region_id=reg.id
     WHERE r.id=${rate.id} """);
    final result = fields[0];
    return rate.copyWith(
      critic: result[0],
      wine: result[1],
      locationId: result[2],
      location: result[3],
      domainId: result[4],
      domain: result[5],
      regionId: result[6],
      region: result[7],
      comment: result[8],
      classification: result[9],
    );
  }

  Future<void> remove(Rate rate) async {
    return await db.query("DELETE FROM rate WHERE id=@id",
        substitutionValues: {"id": rate.id});
  }
}
