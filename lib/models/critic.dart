import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_wine_rate/models/paginated_params.dart';
import '../config.dart';

class PaginatedCritics extends PaginatedRows {
  int actualLine;
  int totalLines;
  List<Critic> critics;

  PaginatedCritics(this.actualLine, this.totalLines, this.critics);

  @override
  List<String> rows(int index) => [critics[index].name];
}

class Critic {
  String name;
  int id;

  Critic({@required this.id, @required this.name});

  Critic copy() => Critic(id: id, name: name);

  static Future<List<Critic>> getAll(Config config) {
    return config.query("SELECT id,name FROM critics").then(
        (results) => results.map((e) => Critic(id: e[0], name: e[1])).toList());
  }

  static Future<PaginatedCritics> getPaginated(
      Config config, PaginatedParams params) async {
    final courtResults = await config.query(
        "SELECT count(1) FROM critics WHERE name ILIKE @search",
        values: {"search": '%${params.search}%'});
    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = params.sort == FieldSort.NameSort ? 2 : 1;
    final critics = await config.query(
        'select id,name FROM critics WHERE name ILIKE @search ORDER BY @sort LIMIT 10 OFFSET @offset',
        values: {
          "sort": sort,
          "offset": actualLine - 1,
          'search': '%${params.search}%'
        }).then(
        (results) => results.map((e) => Critic(id: e[0], name: e[1])).toList());
    return PaginatedCritics(actualLine, totalLines, critics);
  }

  Future<void> add(Config config) async {
    final results = await config.query(
        "INSERT INTO critics (name) VALUES (@name) RETURNING id",
        values: {"name": name});
    id = results[0][0];
  }

  Future<void> update(Config config) async {
    await config.query("UPDATE critics SET name=@name WHERE id=@id",
        values: {"name": name, "id": id});
  }

  Future<void> remove(Config config) async {
    await config.query("DELETE FROM critics WHERE id=@id", values: {"id": id});
  }
}
