import 'package:flutter/material.dart';

import 'pagination.dart';

class Location extends EquatableWithName {
  final int id;
  final String name;
  final int regionId;
  final String region;
  static const tableHeaders = [
    PaginatedHeader('Nom', FieldSort.Name),
    PaginatedHeader('Region', FieldSort.Region)
  ];

  Location({
    @required this.id,
    @required this.name,
    @required this.regionId,
    @required this.region,
  });

  Location copyWith({String name, int id, String region, int regionId}) =>
      Location(
        id: id ?? this.id,
        name: name ?? this.name,
        regionId: regionId ?? this.regionId,
        region: region ?? this.region,
      );

  @override
  List<Object> get props => [id, name, regionId, region];

  @override
  String toString() {
    return 'Location { id: $id, name: $name, regionId: $regionId, region: $region }';
  }

  @override
  String displayName() => '$name [$region]';

  @override
  List<String> rows() => [name, region];
}
