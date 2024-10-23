import 'dart:async';

import 'package:book/app_user_singleton.dart';
import 'package:book/core/constants.dart';
import 'package:book/data/firebase_auth_manager.dart';
import 'package:book/data/firebase_db_manager.dart';
import 'package:book/login/bloc/login_event.dart';
import 'package:book/login/bloc/login_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_mail_app/open_mail_app.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(InitialState()) {
    on<SignUpEvent>(_onSignUpEvent);
    on<Login>(_onLogin);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<CreateUserWithGoogleEvent>(_onCreateUserWithGoogle);
    on<SignUpWithProviderEvent>(_onSignUpWithProvider);
    on<SignInWithFacebookEvent>(_onSignInWithFacebook);
    on<CreateUserWithFacebookEvent>(_onCreateUserWithFacebook);
    on<OpenMailAppEvent>(_onOpenMailApp);
  }

  Future<void> _onSignUpEvent(
      SignUpEvent event, Emitter<LoginState> emit) async {
    emit(LoadingState());
    try {
      await FirebaseAuthManager.instance.registerUser(event.user);
      await FirebaseAuthManager.instance.sendEmailVerification();
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
      if (FirebaseAuthManager.instance.auth.currentUser!.emailVerified) {
        final result = await AppUserSingleton.instance.fetchCurrentUser();
        if (result != null) {
          emit(LoadedState());
          emit(
            SuccessfulLogin(),
          );
        }
      } else {
        emit(LoadedState());
        emit(VerifyEmailState());
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

  Future<void> _onSignInWithGoogle(
      SignInWithGoogleEvent event, Emitter<LoginState> emit) async {
    try {
      final result = await FirebaseAuthManager.instance.signInWithGoogle();
      emit(SignInWithGoogleState(credential: result));
    } on Exception catch (e) {
      emit(ErrorState(error: e));
    }
  }

  Future<void> _onCreateUserWithGoogle(
      CreateUserWithGoogleEvent event, Emitter<LoginState> emit) async {
    try {
      final result =
          await FirebaseDbManager.instance.loginExistingUser(event.credential);

      if (result != null) {
        final userResult = await AppUserSingleton.instance.fetchCurrentUser();
        if (userResult != null) {
          emit(SuccessfulLogin());
        }
      } else {
        emit(CreateUserWithGoogleState(credential: event.credential));
      }
    } on Exception catch (e) {
      emit(ErrorState(error: e));
    }
  }

  Future<void> _onSignUpWithProvider(
      SignUpWithProviderEvent event, Emitter<LoginState> emit) async {
    try {
      await FirebaseAuthManager.instance.sendEmailVerification();
      await FirebaseAuthManager.instance.addUserToDatabase(event.user);
      emit(SuccessfulSignUp());
    } on Exception catch (e) {
      emit(ErrorState(error: e));
    }
  }

  Future<void> _onSignInWithFacebook(
      SignInWithFacebookEvent event, Emitter<LoginState> emit) async {
    try {
      final result = await FirebaseAuthManager.instance.signInWithFacebook();
      emit(SignInWithFacebookState(credential: result));
    } on FirebaseAuthException catch (e) {
      if (e.code == accountExist) {
        emit(SignInWithDifferentProviderState());
      }
    } on Exception catch (e) {
      emit(ErrorState(error: e));
    }
  }

  Future<void> _onCreateUserWithFacebook(
      CreateUserWithFacebookEvent event, Emitter<LoginState> emit) async {
    try {
      final result =
          await FirebaseDbManager.instance.loginExistingUser(event.credential);
      if (result != null) {
        if (FirebaseAuthManager.instance.auth.currentUser!.emailVerified) {
          final userResult = await AppUserSingleton.instance.fetchCurrentUser();
          if (userResult != null) {
            emit(SuccessfulLogin());
          }
        } else {
          emit(VerifyEmailState());
        }
      } else {
        emit(CreateUserWithFacebookState(credential: event.credential));
      }
    } on Exception catch (e) {
      emit(ErrorState(error: e));
    }
  }

  Future<void> _onOpenMailApp(
      OpenMailAppEvent event, Emitter<LoginState> emit) async {
    try {
      final mail = await OpenMailApp.openMailApp();
      if (!mail.didOpen && !mail.canOpen) {
        emit(CanNotOpenMailState());
      } else if (!mail.didOpen && mail.canOpen) {
        emit(MailAppDidNotOpenState(mailApps: mail));
      }
    } on Exception catch (e) {
      emit(ErrorState(error: e));
    }
  }
}
