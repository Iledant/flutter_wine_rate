import 'package:flutter/material.dart';

import 'pagination.dart';

class Critic extends EquatableWithName {
  final String name;
  final int id;
  static const tableHeaders = [const PaginatedHeader('Nom', FieldSort.Name)];

  const Critic({@required this.id, @required this.name});

  Critic copyWith({String name, int id}) =>
      Critic(name: name ?? this.name, id: id ?? this.id);

  @override
  List<Object> get props => [id, name];

  @override
  String toString() {
    return 'Critic { id: $id, name: $name }';
  }

  @override
  String displayName() => name;

  // @override
  // List<PaginatedHeader> headers() => [PaginatedHeader('Nom', FieldSort.Name)];

  @override
  List<String> rows() => [name];
}
