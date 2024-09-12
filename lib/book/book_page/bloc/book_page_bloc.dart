import 'dart:async';
import 'dart:ui' as ui;

import 'package:book/book/book.dart';
import 'package:book/book/book_data.dart';
import 'package:book/core/constants.dart';
import 'package:book/data/firebase_db_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'book_page_event.dart';
import 'book_page_state.dart';

class BookPageBloc extends Bloc<BookPageEvent, BookPageState> {
  BookPageBloc() : super(InitialState()) {
    on<AddBookPageImageEvent>(_onAddBookPageImage);
    on<DeleteBookPageImageEvent>(_onDeleteBookPageImage);
    on<SaveNewBookPageEvent>(_onSaveBookPage);
    on<AddBookPageEvent>(_onAddBookPage);
    on<InitBookEvent>(_onInitBookPage);
    on<PreviousPageEvent>(_onPreviousPage);
    on<NextPageEvent>(_onNextPage);
    on<AddNewBookChapterEvent>(_onAddNewBookChapter);
    on<BackToPageViewEvent>(_onBackToPageView);
    on<ChangeSelectedChapterEvent>(_onChangeSelectedChapter);
    on<SaveBookChapterEvent>(_onSaveBookChapter);
  }

  late Book book;
  int currentPageIndex = 0;

  Future<void> _onAddBookPageImage(
      AddBookPageImageEvent event, Emitter<BookPageState> emit) async {
    ui.Image decodedImage;
    emit(LoadingState());
    try {
      decodedImage = await decodeImageFromList(event.image!.readAsBytesSync())
          .timeout(Duration(seconds: 3), onTimeout: () {
        throw Exception(serverError);
      });
      emit(LoadedState());
      emit(AddBookPageImageState(
          image: event.image, decodedImage: decodedImage));
    } on Exception catch (e) {
      emit(ErrorState(
          error: e, bookData: book.bookData!, pageIndex: currentPageIndex));
      emit(LoadedState());
    }
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
      emit(LoadedState());
    }
  }

  Future<void> _onAddBookPage(
      AddBookPageEvent event, Emitter<BookPageState> emit) async {
    book.bookData!.bookPages.add(event.page);
    currentPageIndex = book.bookData!.bookPages.indexOf(event.page);
    emit(LoadingState());
    try {
      await FirebaseDbManager.instance
          .uploadPages(book.bookData!.bookPages, book.docId);
      emit(LoadedState());
      emit(DisplayBookPageState(
          bookData: book.bookData!, pageIndex: currentPageIndex));
    } on Exception catch (e) {
      emit(LoadedState());
      emit(ErrorState(
          error: e, bookData: book.bookData!, pageIndex: currentPageIndex));
    }
  }

  Future<void> _onInitBookPage(
      InitBookEvent event, Emitter<BookPageState> emit) async {
    this.book = event.book;
    if (book.bookData == null) {
      book.bookData = BookData(bookPages: [], bookChapters: []);
    }
    this.currentPageIndex = 0;
    emit(LoadingState());
    try {
      final result =
          await FirebaseDbManager.instance.downloadFromServer(book.docId);
      emit(LoadedState());
      book.bookData = result;

      emit(DisplayBookPageState(
          bookData: book.bookData!, pageIndex: currentPageIndex));
    } on Exception catch (e) {
      emit(LoadedState());
      emit(ErrorState(
          error: e, bookData: book.bookData!, pageIndex: currentPageIndex));
    }
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

  Future<void> _onAddNewBookChapter(
      AddNewBookChapterEvent event, Emitter<BookPageState> emit) async {
    book.bookData!.bookChapters.add(event.chapter);
    emit(LoadingState());
    try {
      await FirebaseDbManager.instance
          .uploadChapters(book.bookData!.bookChapters, book.docId);
      emit(LoadedState());
      emit(AddNewBookChapterState(chapters: book.bookData!.bookChapters));
    } on Exception catch (e) {
      emit(LoadedState());
      emit(ErrorState(
          error: e, bookData: book.bookData!, pageIndex: currentPageIndex));
    }
  }

  Future<void> _onBackToPageView(
      BackToPageViewEvent event, Emitter<BookPageState> emit) async {
    emit(DisplayBookPageState(
        bookData: book.bookData!, pageIndex: currentPageIndex));
  }

  Future<void> _onChangeSelectedChapter(
      ChangeSelectedChapterEvent event, Emitter<BookPageState> emit) async {
    emit(ChangeSelectedChapterState(chapter: event.chapter));
  }

  Future<void> _onSaveBookChapter(
      SaveBookChapterEvent event, Emitter<BookPageState> emit) async {
    emit(SaveBookChapterState(chapter: event.chapter));
  }
}
