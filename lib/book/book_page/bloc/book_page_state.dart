import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:book/book/book_chapter/book_chapter.dart';
import 'package:book/book/book_data.dart';
import 'package:book/book/book_page/book_page.dart';
import 'package:equatable/equatable.dart';

sealed class BookPageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitialState extends BookPageState {
  InitialState();
}

class AddBookPageImageState extends BookPageState {
  AddBookPageImageState({
    required this.image,
    required this.decodedImage,
  });

  final File? image;
  final ui.Image decodedImage;

  @override
  List<Object?> get props => [
        image,
        Random().nextInt(10000),
      ];
}

class DeleteBookPageImageState extends BookPageState {
  DeleteBookPageImageState();
}

class LoadingState extends BookPageState {
  LoadingState();
}

class LoadedState extends BookPageState {
  LoadedState();
}

class ErrorState extends DisplayBookPageState {
  ErrorState({
    required this.error,
    required super.bookData,
    required super.pageIndex,
  });

  final Exception error;

  @override
  List<Object?> get props => [
        error,
        Random().nextInt(10000),
      ];
}

class SaveNewBookPageState extends BookPageState {
  SaveNewBookPageState({required this.page});

  final BookPage page;

  @override
  List<Object?> get props => [
        page,
        Random().nextInt(10000),
      ];
}

class DisplayBookPageState extends BookPageState {
  DisplayBookPageState({
    required this.bookData,
    required this.pageIndex,
  });

  final BookData bookData;
  final int pageIndex;

  @override
  List<Object?> get props => [
        bookData,
        pageIndex,
        Random().nextInt(10000),
      ];
}

class AddNewBookChapterState extends BookPageState {
  AddNewBookChapterState({required this.chapters});

  final List<BookChapter> chapters;

  @override
  List<Object?> get props => [
        chapters,
        Random().nextInt(10000),
      ];
}

class ChangeSelectedChapterState extends BookPageState {
  ChangeSelectedChapterState({required this.chapter});

  final BookChapter chapter;

  @override
  List<Object?> get props => [
        chapter,
        Random().nextInt(10000),
      ];
}

class SaveBookChapterState extends BookPageState {
  SaveBookChapterState({required this.chapter});

  final BookChapter chapter;

  @override
  List<Object?> get props => [
        chapter,
        Random().nextInt(10000),
      ];
}
