import 'package:flutter/material.dart';
import 'pagination.dart';

class Wine extends EquatableWithName {
  final int id;
  final String name;
  final String classification;
  final String comment;
  final int domainId;
  final String domain;
  final int locationId;
  final String location;
  final int regionId;
  final String region;
  static const tableHeaders = [
    PaginatedHeader('Nom', FieldSort.Name),
    PaginatedHeader('Classement', FieldSort.Classification),
    PaginatedHeader('Commentaire', FieldSort.Comment),
    PaginatedHeader('Domaine', FieldSort.Domain),
    PaginatedHeader('Appellation', FieldSort.Location),
    PaginatedHeader('Région', FieldSort.Region),
  ];

  const Wine({
    @required this.id,
    @required this.name,
    @required this.classification,
    @required this.comment,
    @required this.domainId,
    @required this.domain,
    @required this.locationId,
    @required this.location,
    @required this.regionId,
    @required this.region,
  });

  @override
  List<String> rows() =>
      [name, classification ?? '', comment ?? '', domain, location, region];

  @override
  List<Object> get props => [
        id,
        name,
        classification,
        comment,
        domainId,
        domain,
        locationId,
        location,
        regionId,
        region
      ];

  Wine copyWith({
    int id,
    String name,
    String classification,
    String comment,
    int domainId,
    String domain,
    int locationId,
    String location,
    int regionId,
    String region,
  }) =>
      Wine(
        id: id ?? this.id,
        name: name ?? this.name,
        classification: classification ?? this.classification,
        comment: comment ?? this.comment,
        domainId: domainId ?? this.domainId,
        domain: domain ?? this.domain,
        locationId: locationId ?? this.locationId,
        location: location ?? this.location,
        regionId: regionId ?? this.regionId,
        region: region ?? this.region,
      );

  @override
  String displayName() => '$name [$domain]';
}
