import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

sealed class HomeState extends Equatable{

  @override
  List<Object?> get props => [];
}


class InitialState extends HomeState{
  InitialState();
}

class SuccessfulSignOut extends HomeState{
  SuccessfulSignOut();
}

class ErrorState extends HomeState{

ErrorState({required this.error});

  final Exception error;

  @override
  List<Object?> get props => [error, Random().nextInt(10000)];
}