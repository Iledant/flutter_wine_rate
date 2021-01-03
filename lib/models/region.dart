import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Region extends Equatable {
  final String name;
  final int id;

  const Region({@required this.id, @required this.name});

  Region copyWith({String name, int id}) =>
      Region(id: id ?? this.id, name: name ?? this.name);

  @override
  List<Object> get props => [id, name];

  @override
  String toString() {
    return 'Region { id: $id, name: $name }';
  }
}
