import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Bank extends Equatable {
  const Bank({required this.name});

  final String name;

  @override
  List<Object?> get props => [name];
}
