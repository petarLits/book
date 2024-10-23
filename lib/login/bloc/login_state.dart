import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:open_mail_app/open_mail_app.dart';

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

class SignInWithGoogleState extends LoginState {
  SignInWithGoogleState({required this.credential});

  final UserCredential credential;

  @override
  List<Object?> get props => [credential];
}

class CreateUserWithGoogleState extends LoginState {
  CreateUserWithGoogleState({required this.credential});

  final UserCredential credential;

  @override
  List<Object?> get props => [credential];
}

class SignInWithFacebookState extends LoginState {
  SignInWithFacebookState({required this.credential});

  final UserCredential credential;

  @override
  List<Object?> get props => [credential];
}

class CreateUserWithFacebookState extends LoginState {
  CreateUserWithFacebookState({required this.credential});

  final UserCredential credential;

  @override
  List<Object?> get props => [this.credential];
}

class SignInWithDifferentProviderState extends LoginState {}

class VerifyEmailState extends LoginState {}

class CanNotOpenMailState extends LoginState {}

class MailAppDidNotOpenState extends LoginState {
  MailAppDidNotOpenState({required this.mailApps});

  final OpenMailAppResult mailApps;
}
