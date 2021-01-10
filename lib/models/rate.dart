import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Rate extends Equatable {
  final int id;
  final int criticId;
  final String critic;
  final int wineId;
  final String wine;
  final DateTime published;
  final double rate;
  final int year;

  const Rate({
    @required this.id,
    @required this.criticId,
    @required this.critic,
    @required this.wineId,
    @required this.wine,
    @required this.published,
    @required this.rate,
    @required this.year,
  });

  @override
  List<Object> get props => [
        id,
        criticId,
        critic,
        wineId,
        wine,
        published,
        rate,
        year,
      ];

  Rate copyWith({
    int id,
    int criticId,
    String critic,
    int wineId,
    String wine,
    DateTime published,
    double rate,
    int year,
  }) =>
      Rate(
        id: id ?? this.id,
        criticId: criticId ?? this.criticId,
        critic: critic ?? this.critic,
        wineId: wineId ?? this.wineId,
        wine: wine ?? this.wine,
        published: published ?? this.published,
        rate: rate ?? this.rate,
        year: year ?? this.year,
      );
}
