import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Location extends Equatable {
  final int id;
  final String name;
  final int regionId;
  final String region;

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
}
