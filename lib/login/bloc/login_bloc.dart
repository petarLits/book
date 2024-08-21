import 'dart:async';
import 'package:book/data/firebase_auth_manager.dart';
import 'package:book/login/bloc/login_event.dart';
import 'package:book/login/bloc/login_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  LoginBloc() : super(InitialState()) {
    on<SignUpEvent>(_onSignUpEvent);
    on<Login>(_onLogin);
  }

  FirebaseAuthManager authManager = FirebaseAuthManager();

  Future<void> _onSignUpEvent(
      SignUpEvent event, Emitter<LoginState> emit) async {
    try {
      await authManager.registerUser(event.user);
      emit(SuccessfulSignUp());
    } on FirebaseAuthException catch (e) {
      emit(SignUpErrorAuth(error: e));
    } on Exception catch (e) {
      emit(ErrorState(error: e));
    }
  }

  Future<void> _onLogin(Login event, Emitter<LoginState> emit) async {
    try {
      await authManager.loginUser(event.email, event.password);
      emit(
        SuccessfulLogin(),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        ErrorAuthState(error: e),
      );
    } on Exception catch (e) {
      emit(
        ErrorState(error: e),
      );
    }
  }
}
