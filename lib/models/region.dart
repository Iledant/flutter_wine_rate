import 'package:flutter/material.dart';

import 'pagination.dart';

class Region extends EquatableWithName {
  final String name;
  final int id;
  static const tableHeaders = [PaginatedHeader('Nom', FieldSort.Name)];

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
  String displayName() => name;

  @override
  List<String> rows() => [name];
}
