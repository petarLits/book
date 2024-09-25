import 'dart:async';
import 'dart:ui' as ui;

import 'package:book/book/book.dart';
import 'package:book/core/constants.dart';
import 'package:book/data/firebase_db_manager.dart';
import 'package:book/data/firebase_message_manager.dart';
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
    on<UpdateBookPagesEvent>(_onUpdateBookPages);
    on<DeleteBookPageEvent>(_onDeleteBookPage);
    on<NavigateToPageEvent>(_onNavigateToPage);
    on<SwipeLeftEvent>(_onSwipeLeft);
    on<SwipeRightEvent>(_onSwipeRight);
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
    for (int i = 0; i < book.bookData!.bookPages.length; i++) {
      if (book.bookData!.bookPages[i].chapter!.number >
          event.page.chapter!.number) {
        book.bookData!.bookPages[i].pageNumber++;
        event.page.pageNumber--;
      }
    }
    book.bookData!.bookPages.add(event.page);
    book.bookData!.bookPages
        .sort((page1, page2) => page1.pageNumber.compareTo(page2.pageNumber));
    currentPageIndex = book.bookData!.bookPages.indexOf(event.page);
    emit(LoadingState());
    try {
      await FirebaseDbManager.instance
          .uploadPages(book.bookData!.bookPages, book.docId);
      emit(LoadedState());
      Map<String, dynamic> additionalData = {
        'action': messagePageAction,
        'bookId': book.docId,
        'index': currentPageIndex.toString()
      };
      final result = await FirebaseMessageManager.instance.sendPushMessage(
          topic: topic,
          title: event.messageTitle,
          body:event.messageBody,
          additionalData: additionalData);
      if (result == true) {
        emit(DisplayBookPageState(
            bookData: book.bookData!, pageIndex: currentPageIndex));
      }
    } on Exception catch (e) {
      emit(LoadedState());
      emit(ErrorState(
          error: e, bookData: book.bookData!, pageIndex: currentPageIndex));
    }
  }

  Future<void> _onInitBookPage(
      InitBookEvent event, Emitter<BookPageState> emit) async {
    this.book = event.book;
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

  Future<void> _onUpdateBookPages(
      UpdateBookPagesEvent event, Emitter<BookPageState> emit) async {
    emit(LoadingState());
    book.bookData!.bookPages[currentPageIndex] = event.page;
    try {
      await FirebaseDbManager.instance
          .updateServerPages(book.bookData!.bookPages, book.docId);
      emit(LoadedState());
      Map<String, dynamic> additionalData = {
        'action': messagePageAction,
        'bookId': book.docId,
        'index': currentPageIndex.toString()
      };
      final result = await FirebaseMessageManager.instance.sendPushMessage(
        additionalData: additionalData,
        title: event.messageTitle,
        body: event.messageBody,
        topic: topic,
      );
      if (result == true) {
        emit(DisplayBookPageState(
            bookData: book.bookData!, pageIndex: currentPageIndex));
      }
    } on Exception catch (e) {
      emit(LoadedState());
      emit(ErrorState(
          error: e, bookData: book.bookData!, pageIndex: currentPageIndex));
    }
  }

  Future<void> _onDeleteBookPage(
      DeleteBookPageEvent event, Emitter<BookPageState> emit) async {
    emit(LoadingState());
    try {
      await FirebaseDbManager.instance
          .removePage(book.bookData!.bookPages[currentPageIndex], book.docId);
      emit(LoadedState());
      Map<String, dynamic> additionalData = {
        'action': messagePageAction,
        'bookId': book.docId,
      };
      final result = await FirebaseMessageManager.instance.sendPushMessage(
        additionalData: additionalData,
        topic: topic,
        title: event.messageTitle,
        body: event.messageBody,
      );
      if (result == true) {
        book.bookData!.bookPages.removeAt(currentPageIndex);
        for (int i = currentPageIndex;
            i < book.bookData!.bookPages.length;
            i++) {
          book.bookData!.bookPages[i].pageNumber--;
        }
        if (currentPageIndex == book.bookData!.bookPages.length &&
            currentPageIndex > 0) {
          currentPageIndex--;
        }
        emit(DisplayBookPageState(
            bookData: book.bookData!, pageIndex: currentPageIndex));
      }
    } on Exception catch (e) {
      emit(LoadedState());
      emit(ErrorState(
          error: e, bookData: book.bookData!, pageIndex: currentPageIndex));
    }
  }

  Future<void> _onNavigateToPage(
      NavigateToPageEvent event, Emitter<BookPageState> emit) async {
    emit(DisplayBookPageState(
        bookData: book.bookData!, pageIndex: event.pageNumber - 1));
  }

  Future<void> _onSwipeLeft(
      SwipeLeftEvent event, Emitter<BookPageState> emit) async {
    if (currentPageIndex < book.bookData!.bookPages.length - 1) {
      currentPageIndex++;
    }
    emit(DisplayBookPageState(
        bookData: book.bookData!, pageIndex: currentPageIndex));
  }

  Future<void> _onSwipeRight(
      SwipeRightEvent event, Emitter<BookPageState> emit) async {
    if (currentPageIndex > 0) {
      currentPageIndex--;
    }
    emit(DisplayBookPageState(
        bookData: book.bookData!, pageIndex: currentPageIndex));
  }
}
