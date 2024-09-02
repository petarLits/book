import 'dart:async';
import 'package:book/app_user_singleton.dart';
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

  Future<void> _onSignUpEvent(
      SignUpEvent event, Emitter<LoginState> emit) async {
    emit(LoadingState());
    try {
      await FirebaseAuthManager.instance.registerUser(event.user);
      emit(SuccessfulSignUp());
    } on FirebaseAuthException catch (e) {
      emit(SignUpErrorAuth(error: e));
    } on Exception catch (e) {
      emit(ErrorState(error: e));
    } finally {
      emit(LoadedState());
    }
  }

  Future<void> _onLogin(Login event, Emitter<LoginState> emit) async {
    emit(LoadingState());
    try {
      await FirebaseAuthManager.instance.loginUser(
        event.email,
        event.password,
      );
      final result = await AppUserSingleton.instance.fetchCurrentUser();
      if (result != null) {
        emit(LoadedState());
        emit(
          SuccessfulLogin(),
        );
      }
    } on FirebaseAuthException catch (e) {
      emit(
        ErrorAuthState(error: e),
      );
      emit(LoadedState());
    } on Exception catch (e) {
      emit(
        ErrorState(error: e),
      );
      emit(LoadedState());
    }
  }
}
