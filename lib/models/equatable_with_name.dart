import 'package:equatable/equatable.dart';

abstract class EquatableWithName extends Equatable {
  String displayName();

  const EquatableWithName() : super();
}
