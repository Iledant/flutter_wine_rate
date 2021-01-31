import 'package:flutter/material.dart';

import 'equatable_with_name.dart';

class Domain extends EquatableWithName {
  final String name;
  final int id;

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
}
