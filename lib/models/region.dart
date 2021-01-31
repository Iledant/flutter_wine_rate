import 'package:flutter/material.dart';

import 'equatable_with_name.dart';

class Region extends EquatableWithName {
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

  @override
  String displayName() {
    return name;
  }
}
