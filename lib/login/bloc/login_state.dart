import 'dart:math';

import 'package:equatable/equatable.dart';

sealed class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitialState extends LoginState {
  InitialState();
}

class SuccessfulSignUp extends LoginState {
  SuccessfulSignUp();

  @override
  List<Object?> get props => [Random().nextInt(10000)];
}

class ErrorAuthState extends LoginState {
  ErrorAuthState({required this.error});

  final Exception error;
  
  @override
  List<Object?> get props => [Random().nextInt(10000)];
}

class ErrorState extends LoginState{
  ErrorState({required this.error});
  final Exception error;
  
  @override
  List<Object?> get props => [Random().nextInt(10000)];
}

class SuccessfulLogin extends LoginState{
  SuccessfulLogin();

  @override
  List<Object?> get props => [Random().nextInt(10000)];
}
