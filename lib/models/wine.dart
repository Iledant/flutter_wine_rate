import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Wine extends Equatable {
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
}
