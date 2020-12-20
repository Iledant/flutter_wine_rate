import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_wine_rate/models/pagination.dart';
import '../config.dart';

class PaginatedDomains extends PaginatedRows {
  int actualLine;
  int totalLines;
  List<Domain> domains;

  PaginatedDomains(this.actualLine, this.totalLines, this.domains);

  @override
  List<String> rows(int index) => [domains[index].name];

  @override
  List<String> headers() => ['Nom'];
}

class Domain {
  String name;
  int id;

  Domain({@required this.id, @required this.name});

  Domain copy() => Domain(id: id, name: name);

  static Future<List<Domain>> getAll(Config config) {
    return config.query("SELECT id,name FROM domain").then(
        (results) => results.map((e) => Domain(id: e[0], name: e[1])).toList());
  }

  static Future<PaginatedDomains> getPaginated(
      Config config, PaginatedParams params) async {
    final courtResults = await config.query(
        "SELECT count(1) FROM domain WHERE name ILIKE @search",
        values: {"search": '%${params.search}%'});
    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = params.sort == FieldSort.NameSort ? 2 : 1;
    final domains = await config.query(
        "SELECT id,name FROM domain WHERE name ILIKE @search ORDER BY @sort LIMIT 10 OFFSET @offset",
        values: {
          "sort": sort,
          "offset": actualLine - 1,
          'search': '%${params.search}%'
        }).then(
        (results) => results.map((e) => Domain(id: e[0], name: e[1])).toList());
    return PaginatedDomains(actualLine, totalLines, domains);
  }

  Future<void> add(Config config) async {
    final results = await config.query(
        "INSERT INTO domain (name) VALUES (@name) RETURNING id",
        values: {"name": name});
    id = results[0][0];
  }

  Future<void> update(Config config) async {
    await config.query("UPDATE domain SET name=@name WHERE id=@id",
        values: {"name": name, "id": id});
  }

  Future<void> remove(Config config) async {
    await config.query("DELETE FROM domain WHERE id=@id", values: {"id": id});
  }
}
