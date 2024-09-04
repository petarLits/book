import 'dart:async';

import 'package:book/book/bloc/book_page_event.dart';
import 'package:book/book/bloc/book_page_state.dart';
import 'package:book/data/firebase_db_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookPageBloc extends Bloc<BookPageEvent, BookPageState> {
  BookPageBloc() : super(InitialState()) {
    on<AddBookPageImage>(_onAddBookPageImage);
    on<DeleteBookPageImage>(_onDeleteBookPageImage);
    on<SaveNewBookPage>(_onSaveBookPage);
    on<AddBookPage>(_onAddBookPage);
  }

  Future<void> _onAddBookPageImage(
      AddBookPageImage event, Emitter<BookPageState> emit) async {
    emit(BookPageImageAdded(image: event.image));
  }

  Future<void> _onDeleteBookPageImage(
      DeleteBookPageImage event, Emitter<BookPageState> emit) async {
    emit(BookPageImageDeleted());
  }


  Future<void> _onSaveBookPage(
      SaveNewBookPage event, Emitter<BookPageState> emit) async {
    emit(LoadingState());
    try{
      if(event.page.pageImage != null){
      await FirebaseDbManager.instance.uploadPageImageGetUrl(event.page);
      }
      emit(LoadedState());
      emit(NewBookPageSaved(page: event.page));

    }on Exception catch(e){
      emit(ErrorState(error: e));
    }
  }

  Future<void> _onAddBookPage(
      AddBookPage event, Emitter<BookPageState> emit) async {
    emit(AddBookPageState(page: event.page));
  }

}
