import 'package:flutter/material.dart';

import 'pagination.dart';

class Domain extends EquatableWithName {
  final String name;
  final int id;
  static const tableHeaders = [PaginatedHeader('Nom', FieldSort.Name)];

  const Domain({@required this.id, @required this.name});

  Domain copyWith({String name, int id}) =>
      Domain(id: id ?? this.id, name: name ?? this.name);

  @override
  List<Object> get props => [id, name];

  @override
  String toString() {
    return 'Domain { id: $id, name: $name }';
  }

  @override
  String displayName() => name;

  @override
  List<String> rows() => [name];
}
