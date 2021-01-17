import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Rate extends Equatable {
  final int id;
  final int criticId;
  final String critic;
  final int wineId;
  final String wine;
  final String comment;
  final String classification;
  final int locationId;
  final String location;
  final int domainId;
  final String domain;
  final int regionId;
  final String region;
  final DateTime published;
  final double rate;
  final int year;

  const Rate({
    @required this.id,
    @required this.criticId,
    @required this.critic,
    @required this.wineId,
    @required this.wine,
    @required this.locationId,
    @required this.location,
    @required this.domainId,
    @required this.domain,
    @required this.regionId,
    @required this.region,
    @required this.published,
    @required this.rate,
    @required this.year,
    @required this.comment,
    @required this.classification,
  });

  @override
  List<Object> get props => [
        id,
        criticId,
        critic,
        wineId,
        wine,
        locationId,
        location,
        domainId,
        domain,
        regionId,
        region,
        published,
        rate,
        year,
        comment,
        classification,
      ];

  Rate copyWith({
    int id,
    int criticId,
    String critic,
    int wineId,
    String wine,
    int locationId,
    String location,
    int domainId,
    String domain,
    int regionId,
    String region,
    DateTime published,
    double rate,
    int year,
    String comment,
    String classification,
  }) =>
      Rate(
        id: id ?? this.id,
        criticId: criticId ?? this.criticId,
        critic: critic ?? this.critic,
        wineId: wineId ?? this.wineId,
        wine: wine ?? this.wine,
        locationId: locationId ?? this.locationId,
        location: location ?? this.location,
        domainId: domainId ?? this.domainId,
        domain: domain ?? this.domain,
        regionId: regionId ?? this.regionId,
        region: region ?? this.region,
        published: published ?? this.published,
        rate: rate ?? this.rate,
        year: year ?? this.year,
        comment: comment ?? this.comment,
        classification: classification ?? this.classification,
      );
}
