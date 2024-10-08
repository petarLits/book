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
  List<Object?> get props => [error, Random().nextInt(10000)];
}

class ErrorState extends LoginState {
  ErrorState({required this.error});

  final Exception error;

  @override
  List<Object?> get props => [error, Random().nextInt(10000)];
}

class SignUpErrorAuth extends LoginState {
  SignUpErrorAuth({required this.error});

  final Exception error;

  @override
  List<Object?> get props => [error, Random().nextInt(10000)];
}

class SuccessfulLogin extends LoginState {
  SuccessfulLogin();

  @override
  List<Object?> get props => [Random().nextInt(10000)];
}

class LoadingState extends LoginState {
  LoadingState();

  @override
  List<Object?> get props => [Random().nextInt(10000)];
}

class LoadedState extends LoginState {
  LoadedState();

  @override
  List<Object?> get props => [Random().nextInt(10000)];
}
