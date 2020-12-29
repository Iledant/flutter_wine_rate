import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_wine_rate/models/pagination.dart';
import '../config.dart';

class PaginatedWines extends PaginatedRows {
  int actualLine;
  int totalLines;
  List<Wine> wines;

  PaginatedWines(this.actualLine, this.totalLines, this.wines);

  @override
  List<String> rows(int index) => [wines[index].name, wines[index].region];

  @override
  List<PaginatedHeader> headers() => [
        PaginatedHeader('Nom', FieldSort.NameSort),
        PaginatedHeader('Région', FieldSort.RegionSort)
      ];
}

class Wine {
  int id;
  String name;
  String classification;
  String comment;
  int domainId;
  String domain;
  int locationId;
  String location;
  int regionId;
  String region;

  Wine({
    @required this.id,
    @required this.name,
    @required this.classification,
    @required this.comment,
    this.domainId,
    this.domain,
    this.locationId,
    this.location,
    this.regionId,
    this.region,
  });

  Wine copy() => Wine(
        id: id,
        name: name,
        classification: classification,
        comment: comment,
        domainId: domainId,
        domain: domain,
        locationId: locationId,
        location: location,
        regionId: regionId,
        region: region,
      );

  static int _getSortField(FieldSort fieldSort) {
    switch (fieldSort) {
      case FieldSort.NameSort:
        return 2;
      case FieldSort.ClassificationSort:
        return 3;
      case FieldSort.CommentSort:
        return 3;
      case FieldSort.NameSort:
        return 2;
      case FieldSort.DomainSort:
        return 6;
      case FieldSort.LocationSort:
        return 8;
      case FieldSort.RegionSort:
        return 10;
      default:
        return 1;
    }
  }

  static Future<PaginatedWines> getPaginated(
      Config config, PaginatedParams params) async {
    final courtResults = await config.query("""SELECT count(1) FROM wine w
          JOIN domain d ON w.domain_id=d.id
          JOIN location l ON w.location_id=l.id
          JOIN region r ON l.region_id=r.id
          WHERE w.name ILIKE '%${params.search}%' OR r.name ILIKE '%${params.search}%'
            OR l.name ILIKE '%${params.search}%' OR d.name ILIKE '%${params.search}%'
            OR w.classification ILIKE '%${params.search}%'
            OR w.comment ILIKE '%${params.search}%'""",
        values: {"search": '%${params.search}%'});
    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = _getSortField(params.sort);
    var results =
        await config.query("""SELECT w.id,w.name,w.classification,w.comment,
          d.id,d.name,l.id,l.name,r.id,r.name FROM wine w
          JOIN domain d ON w.domain_id=d.id
          JOIN location l ON w.location_id=l.id
          JOIN region r ON l.region_id=r.id
          WHERE w.name ILIKE '%${params.search}%' OR r.name ILIKE '%${params.search}%'
            OR l.name ILIKE '%${params.search}%' OR d.name ILIKE '%${params.search}%'
            OR w.classification ILIKE '%${params.search}%'
            OR w.comment ILIKE '%${params.search}%'
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
    return PaginatedWines(actualLine, totalLines, wines);
  }

  Future<void> add(Config config) async {
    final results = await config
        .query("""INSERT INTO wine (name,classification,comment,domain_id,location_id)
          VALUES (@name,@classification,@comment,@domain_id,@location_id)
          RETURNING id""", values: {
      "name": name,
      "classification": classification,
      "comment": comment,
      "domain_id": domainId,
      "location_id": locationId,
    });
    id = results[0][0];
  }

  Future<void> update(Config config) async {
    final results = await config
        .query("""UPDATE wine SET name=@name,classification=@classification,
          comment=@comment,domain_id=@domain_id,location_id=@location_id
          WHERE id=@id""", values: {
      "id": id,
      "name": name,
      "classification": classification,
      "comment": comment,
      "domain_id": domainId,
      "location_id": locationId,
    });
  }

  Future<void> remove(Config config) async {
    await config.query("DELETE FROM wine WHERE id=@id", values: {"id": id});
  }
}
