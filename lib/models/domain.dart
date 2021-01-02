import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Domain extends Equatable {
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
}
