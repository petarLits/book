import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:book/book/book.dart';
import 'package:book/book/book_data.dart';
import 'package:book/book/book_page/book_page.dart';
import 'package:book/book/book_page/book_page_image.dart';
import 'package:book/core/constants.dart';
import 'package:book/core/server_error_exception.dart';
import 'package:book/data/firebase_db_manager.dart';
import 'package:book/data/firebase_message_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'book_page_event.dart';
import 'book_page_state.dart';

class BookPageBloc extends Bloc<BookPageEvent, BookPageState> {
  BookPageBloc() : super(InitialState()) {
    on<AddBookPageImageEvent>(
        (event, emit) => _onAddBookPageImage(event, emit));
    on<DeleteBookPageImageEvent>(
        (event, emit) => _onDeleteBookPageImage(event, emit));
    on<SaveNewBookPageEvent>((event, emit) => _onSaveBookPage(event, emit));
    on<AddBookPageEvent>((event, emit) => _onAddBookPage(event, emit));
    on<InitBookEvent>((event, emit) => _onInitBookPage(event, emit));
    on<PreviousPageEvent>((event, emit) => _onPreviousPage(event, emit));
    on<NextPageEvent>((event, emit) => _onNextPage(event, emit));
    on<AddNewBookChapterEvent>(
        (event, emit) => _onAddNewBookChapter(event, emit));
    on<ChangeSelectedChapterEvent>(
        (event, emit) => _onChangeSelectedChapter(event, emit));
    on<SaveBookChapterEvent>((event, emit) => _onSaveBookChapter(event, emit));
    on<UpdateBookPagesEvent>((event, emit) => _onUpdateBookPages(event, emit));
    on<DeleteBookPageEvent>((event, emit) => _onDeleteBookPage(event, emit));
    on<NavigateToPageEvent>((event, emit) => _onNavigateToPage(event, emit));
    on<SwipeLeftEvent>((event, emit) => _onSwipeLeft(event, emit));
    on<SwipeRightEvent>((event, emit) => _onSwipeRight(event, emit));
  }

  late Book book;
  int currentPageIndex = 0;

  Future<void> _onAddBookPageImage(
      AddBookPageImageEvent event, Emitter<BookPageState> emit) async {
    final File image = event.image;
    emit(LoadingState());
    emit(AddBookPageImageState(image: image));
  }

  Future<void> _onDeleteBookPageImage(
      DeleteBookPageImageEvent event, Emitter<BookPageState> emit) async {
    emit(DeleteBookPageImageState());
  }

  Future<void> _onSaveBookPage(
      SaveNewBookPageEvent event, Emitter<BookPageState> emit) async {
    emit(LoadingState());
    final BookPage page = event.page;
    final File? image = event.image;
    final ui.Image decodedImage;
    if (image != null) {
      try {
        decodedImage = await decodeImageFromList(image.readAsBytesSync())
            .timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
          throw ServerErrorException();
        });
        final BookPageImage pageImage = BookPageImage(
            width: decodedImage.width,
            height: decodedImage.height,
            image: image);
        page.pageImage = pageImage;
      } on Exception catch (e) {
        emit(ErrorState(
            error: e, bookData: book.bookData!, pageIndex: currentPageIndex));
      }
    }
    try {
      if (page.pageImage?.image != null) {
        await FirebaseDbManager.instance.uploadPageImageGetUrl(event.page);
      }

      emit(SaveNewBookPageState(page: page));
    } on Exception catch (e) {
      emit(ErrorState(
          error: e, bookData: book.bookData!, pageIndex: currentPageIndex));
    }
  }

  Future<void> _onAddBookPage(
      AddBookPageEvent event, Emitter<BookPageState> emit) async {
    final BookPage page = event.page;
    for (int i = 0; i < book.bookData!.bookPages.length; i++) {
      if (book.bookData!.bookPages[i].chapter!.number > page.chapter!.number) {
        book.bookData!.bookPages[i].pageNumber++;
        page.pageNumber--;
      }
    }
    book.bookData!.bookPages.insert(page.pageNumber - 1, page);
    currentPageIndex = book.bookData!.bookPages.indexOf(page);
    emit(LoadingState());
    try {
      await FirebaseDbManager.instance
          .uploadPages(book.bookData!.bookPages, book.docId);
      Map<String, dynamic> additionalData = {
        'action': messagePageAction,
        'bookId': book.docId,
        'index': currentPageIndex.toString()
      };
      final result = await FirebaseMessageManager.instance.sendPushMessage(
          topic: topic,
          title: event.messageTitle,
          body: event.messageBody,
          additionalData: additionalData);
      if (result == true) {
        emit(DisplayBookPageState(
            bookData: book.bookData!, pageIndex: currentPageIndex));
      } else {
        throw Exception();
      }
    } on Exception catch (e) {
      emit(ErrorState(
          error: e, bookData: book.bookData!, pageIndex: currentPageIndex));
    }
  }

  Future<void> _onInitBookPage(
      InitBookEvent event, Emitter<BookPageState> emit) async {
    this.book = event.book;
    emit(LoadingState());
    if (this.book.bookData == null) {
      book.bookData = BookData.emptyData();
    }
    try {
      final result =
          await FirebaseDbManager.instance.downloadFromServer(book.docId);
      book.bookData = result;
      emit(DisplayBookPageState(
        bookData: book.bookData!,
        pageIndex: currentPageIndex,
      ));
    } on Exception catch (e) {
      emit(ErrorState(
        error: e,
        bookData: book.bookData!,
        pageIndex: currentPageIndex,
      ));
    }
  }

  Future<void> _onPreviousPage(
      PreviousPageEvent event, Emitter<BookPageState> emit) async {
    this.currentPageIndex = event.pageIndex - 1;
    emit(DisplayBookPageState(
      bookData: book.bookData!,
      pageIndex: currentPageIndex,
    ));
  }

  Future<void> _onNextPage(
      NextPageEvent event, Emitter<BookPageState> emit) async {
    this.currentPageIndex = event.pageIndex + 1;
    emit(DisplayBookPageState(
      bookData: book.bookData!,
      pageIndex: currentPageIndex,
    ));
  }

  Future<void> _onAddNewBookChapter(
      AddNewBookChapterEvent event, Emitter<BookPageState> emit) async {
    book.bookData!.bookChapters.add(event.chapter);
    emit(LoadingState());
    try {
      await FirebaseDbManager.instance.uploadChapters(
        book.bookData!.bookChapters,
        book.docId,
      );
      emit(AddNewBookChapterState(chapters: book.bookData!.bookChapters));
    } on Exception catch (e) {
      emit(ErrorState(
        error: e,
        bookData: book.bookData!,
        pageIndex: currentPageIndex,
      ));
    }
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
      await FirebaseDbManager.instance.updateServerPages(
        book.bookData!.bookPages,
        book.docId,
      );
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
          bookData: book.bookData!,
          pageIndex: currentPageIndex,
        ));
      } else {
        throw Exception();
      }
    } on Exception catch (e) {
      emit(ErrorState(
        error: e,
        bookData: book.bookData!,
        pageIndex: currentPageIndex,
      ));
    }
  }

  Future<void> _onDeleteBookPage(
      DeleteBookPageEvent event, Emitter<BookPageState> emit) async {
    emit(LoadingState());
    try {
      await FirebaseDbManager.instance.removePage(
        book.bookData!.bookPages[currentPageIndex],
        book.docId,
      );
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
          bookData: book.bookData!,
          pageIndex: currentPageIndex,
        ));
      } else {
        throw Exception();
      }
    } on Exception catch (e) {
      emit(ErrorState(
        error: e,
        bookData: book.bookData!,
        pageIndex: currentPageIndex,
      ));
    }
  }

  Future<void> _onNavigateToPage(
      NavigateToPageEvent event, Emitter<BookPageState> emit) async {
    emit(DisplayBookPageState(
      bookData: book.bookData!,
      pageIndex: event.pageNumber - 1,
    ));
  }

  Future<void> _onSwipeLeft(
      SwipeLeftEvent event, Emitter<BookPageState> emit) async {
    if (currentPageIndex < book.bookData!.bookPages.length - 1) {
      currentPageIndex++;
    }
    emit(DisplayBookPageState(
      bookData: book.bookData!,
      pageIndex: currentPageIndex,
    ));
  }

  Future<void> _onSwipeRight(
      SwipeRightEvent event, Emitter<BookPageState> emit) async {
    if (currentPageIndex > 0) {
      currentPageIndex--;
    }
    emit(DisplayBookPageState(
      bookData: book.bookData!,
      pageIndex: currentPageIndex,
    ));
  }
}
