import 'dart:async';

import 'package:book/app_user_singleton.dart';
import 'package:book/core/constants.dart';
import 'package:book/data/firebase_auth_manager.dart';
import 'package:book/data/firebase_db_manager.dart';
import 'package:book/data/firebase_message_manager.dart';
import 'package:book/home/bloc/home_event.dart';
import 'package:book/home/bloc/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(InitialState()) {
    on<SignOut>(_onSignOut);
    on<UploadBook>(_onUploadBook);
    on<SaveNewBook>(_onSaveNewBook);
    on<AddBookImage>(_onAddBookImage);
    on<UploadBookImageAndGetUrl>(_onUploadBookImage);
    on<DeleteBookImage>(_onDeleteBookImage);
    on<DownloadBooksEvent>(_onDownloadBooks);
  }

  Future<void> _onSignOut(SignOut event, Emitter<HomeState> emit) async {
    emit(LoadingState());

    try {
      await FirebaseAuthManager.instance.signOut();
      AppUserSingleton.instance.clearAppUser();
      emit(LoadedState());
      emit(SuccessfulSignOut());
    } on Exception catch (e) {
      emit(ErrorState(error: e));
      emit(LoadedState());
    }
  }

  Future<void> _onUploadBook(UploadBook event, Emitter<HomeState> emit) async {
    emit(LoadingState());

    try {
      await FirebaseDbManager.instance.uploadBook(event.book);
      emit(LoadedState());
      final result = await FirebaseMessageManager.instance.sendPushMessage(
          additionalData: {'action': messageBookAction},
          topic: topic,
          title: 'New book: ' + event.book.title,
          body: 'Author ' + event.book.author + ' has just published new book',
          imageUrl: event.book.imageUrl);
      if (result == true) {
        emit(UploadedBookState(book: event.book));
      }
    } on Exception catch (e) {
      emit(ErrorState(error: e));
      emit(LoadedState());
    }
  }

  Future<void> _onSaveNewBook(
      SaveNewBook event, Emitter<HomeState> emit) async {
    emit(SavedBookState(book: event.book));
  }

  Future<void> _onAddBookImage(
      AddBookImage event, Emitter<HomeState> emit) async {
    emit(AddBookImageState(image: event.image));
  }

  Future<void> _onUploadBookImage(
      UploadBookImageAndGetUrl event, Emitter<HomeState> emit) async {
    emit(LoadingState());

    try {
      await FirebaseDbManager.instance.uploadBookImageAndGetUrl(event.book);
      emit(LoadedState());
      emit(UploadedBookImageAndUrlGotState(book: event.book));
    } on Exception catch (e) {
      emit(ErrorState(error: e));
      emit(LoadedState());
    }
  }

  Future<void> _onDeleteBookImage(
      DeleteBookImage event, Emitter<HomeState> emit) async {
    emit(DeletedBookImage());
  }

  Future<void> _onDownloadBooks(
      DownloadBooksEvent event, Emitter<HomeState> emit) async {
    emit(LoadingState());
    try {
      final result = await FirebaseDbManager.instance.downloadBooks();
      emit(LoadedState());
      emit(DownloadBooksState(books: result));
    } on Exception catch (e) {
      emit(LoadedState());
      emit(ErrorState(error: e));
    }
  }
}
