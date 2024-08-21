import 'package:book/app_user.dart';
import 'package:equatable/equatable.dart';

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
