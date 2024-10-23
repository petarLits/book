import 'package:book/app_user.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

sealed class LoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpEvent extends LoginEvent {
  SignUpEvent({required this.user});

  final AppUser user;

  @override
  List<Object?> get props => [user];
}

class Login extends LoginEvent {
  Login({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class SignInWithGoogleEvent extends LoginEvent {}

class CreateUserWithGoogleEvent extends LoginEvent {
  CreateUserWithGoogleEvent({required this.credential});

  final UserCredential credential;
}

class SignUpWithProviderEvent extends LoginEvent {
  SignUpWithProviderEvent({required this.user});

  final AppUser user;
}

class SignInWithFacebookEvent extends LoginEvent{}

class CreateUserWithFacebookEvent extends LoginEvent{
CreateUserWithFacebookEvent({required this.credential});

  final UserCredential credential;
}

class OpenMailAppEvent extends LoginEvent{}
