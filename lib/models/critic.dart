import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Critic extends Equatable {
  final String name;
  final int id;

  const Critic({@required this.id, @required this.name});

  Critic copyWith({String name, int id}) =>
      Critic(name: name ?? this.name, id: id ?? this.id);

  @override
  List<Object> get props => [id, name];

  @override
  String toString() {
    return 'Critics { id: $id, name: $name }';
  }

  // CriticEntity toEntity() {
  //   return CriticEntity(id, name);
  // }

  // static Critic fromEntity(CriticEntity entity) {
  //   return Critic(
  //     name: name,
  //     id: entity.id ?? Uuid().generateV4(),
  //   );
  // }
}
