import 'dart:async';

import 'package:book/app_user_singleton.dart';
import 'package:book/data/firebase_auth_manager.dart';
import 'package:book/home/bloc/home_event.dart';
import 'package:book/home/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(InitialState()) {
    on<SignOut>(_onSignOut);
    on<AddNewBook>(_onAddNewBook);
  }

  Future<void> _onSignOut(SignOut event, Emitter<HomeState> emit) async {
    try {
      await FirebaseAuthManager.instance.signOut();
      AppUserSingleton.instance.clearAppUser();
      emit(
        SuccessfulSignOut(),
      );
    } on Exception catch (e) {
      emit(
        ErrorState(error: e),
      );
    }
  }

  void _onAddNewBook(AddNewBook event, Emitter<HomeState> emit) {
    emit(AddingNewBook());
  }
}
