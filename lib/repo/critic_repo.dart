import 'dart:math';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';

import '../models/critic.dart';
import '../models/pagination.dart';

class PaginatedCritics extends PaginatedRows<Critic> {
  const PaginatedCritics({int actualLine, int totalLines, List<Critic> lines})
      : super(actualLine: actualLine, totalLines: totalLines, lines: lines);

  @override
  List<String> rowCells(int index) => [lines[index].name];

  @override
  List<PaginatedHeader> headers() => [PaginatedHeader('Nom', FieldSort.Name)];
}

class CriticRepository {
  final PostgreSQLConnection db;

  const CriticRepository({@required this.db});

  Future<PaginatedCritics> getPaginated(PaginatedParams params) async {
    final commonQuery = " FROM critics WHERE name ILIKE @search ";
    final courtResults = await db.query("SELECT count(1) " + commonQuery,
        substitutionValues: {"search": '%${params.search}%'});

    final int totalLines = courtResults[0][0];
    final int actualLine = min(params.firstLine, totalLines + 1);
    final int sort = params.sort == FieldSort.Name ? 2 : 1;

    final results = await db.query(
        "SELECT id,name" +
            commonQuery +
            "ORDER BY $sort LIMIT 10 OFFSET @offset",
        substitutionValues: {
          "offset": actualLine - 1,
          'search': '%${params.search}%'
        });

    final lines = results.map((e) => Critic(id: e[0], name: e[1])).toList();

    return PaginatedCritics(
        actualLine: actualLine, totalLines: totalLines, lines: lines);
  }

  Future<Critic> add(Critic critic) async {
    final results = await db.query(
        "INSERT INTO critics (name) VALUES (@name) RETURNING id",
        substitutionValues: {"name": critic.name});
    return critic.copyWith(id: results[0][0]);
  }

  Future<Critic> update(Critic critic) async {
    final results = await db.query(
        """UPDATE critics SET name=@name WHERE id=@id 
    RETURNING id,name""",
        substitutionValues: {"name": critic.name, "id": critic.id});
    return Critic(id: results[0][0], name: results[0][1]);
  }

  Future<void> remove(Critic critic) async {
    await db.query("DELETE FROM critics WHERE id=@id",
        substitutionValues: {"id": critic.id});
  }
}
