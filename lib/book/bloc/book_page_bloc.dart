import 'dart:async';

import 'package:book/book/bloc/book_page_event.dart';
import 'package:book/book/bloc/book_page_state.dart';
import 'package:book/book/book.dart';
import 'package:book/book/book_data.dart';
import 'package:book/data/firebase_db_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookPageBloc extends Bloc<BookPageEvent, BookPageState> {
  BookPageBloc() : super(InitialState()) {
    on<AddBookPageImageEvent>(_onAddBookPageImage);
    on<DeleteBookPageImageEvent>(_onDeleteBookPageImage);
    on<SaveNewBookPageEvent>(_onSaveBookPage);
    on<AddBookPageEvent>(_onAddBookPage);
    on<InitBookEvent>(_onInitBookPage);
    on<PreviousPageEvent>(_onPreviousPage);
    on<NextPageEvent>(_onNextPage);
  }

  late Book book;
  int currentPageIndex = 0;

  Future<void> _onAddBookPageImage(
      AddBookPageImageEvent event, Emitter<BookPageState> emit) async {
    emit(AddBookPageImageState(image: event.image));
  }

  Future<void> _onDeleteBookPageImage(
      DeleteBookPageImageEvent event, Emitter<BookPageState> emit) async {
    emit(DeleteBookPageImageState());
  }

  Future<void> _onSaveBookPage(
      SaveNewBookPageEvent event, Emitter<BookPageState> emit) async {
    emit(LoadingState());
    try {
      if (event.page.pageImage != null) {
        await FirebaseDbManager.instance.uploadPageImageGetUrl(event.page);
      }
      emit(LoadedState());
      emit(SaveNewBookPageState(page: event.page));
    } on Exception catch (e) {
      emit(ErrorState(
          error: e, bookData: book.bookData!, pageIndex: currentPageIndex));
    }
  }

  Future<void> _onAddBookPage(
      AddBookPageEvent event, Emitter<BookPageState> emit) async {
    book.bookData!.bookPages.add(event.page);
    currentPageIndex = book.bookData!.bookPages.indexOf(event.page);
    emit(DisplayBookPageState(
        bookData: book.bookData!, pageIndex: currentPageIndex));
  }

  Future<void> _onInitBookPage(
      InitBookEvent event, Emitter<BookPageState> emit) async {
    this.book = event.book;
    if (book.bookData == null) {
      book.bookData = BookData(bookPages: []);
    }
    this.currentPageIndex = 0;
    emit(DisplayBookPageState(
        bookData: book.bookData!, pageIndex: currentPageIndex));
  }

  Future<void> _onPreviousPage(
      PreviousPageEvent event, Emitter<BookPageState> emit) async {
    this.currentPageIndex = event.pageIndex - 1;
    emit(DisplayBookPageState(
        bookData: book.bookData!, pageIndex: currentPageIndex));
  }

  Future<void> _onNextPage(
      NextPageEvent event, Emitter<BookPageState> emit) async {
    this.currentPageIndex = event.pageIndex + 1;
    emit(DisplayBookPageState(
        bookData: book.bookData!, pageIndex: currentPageIndex));
  }
}
