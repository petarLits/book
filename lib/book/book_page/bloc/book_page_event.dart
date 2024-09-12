import 'dart:io';

import 'package:book/book/book.dart';
import 'package:book/book/book_chapter/book_chapter.dart';
import 'package:book/book/book_page/book_page.dart';
import 'package:equatable/equatable.dart';

sealed class BookPageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddBookPageImageEvent extends BookPageEvent {
  AddBookPageImageEvent({required this.image});

  final File? image;

  @override
  List<Object?> get props => [image];
}

class DeleteBookPageImageEvent extends BookPageEvent {
  DeleteBookPageImageEvent();
}

class SaveNewBookPageEvent extends BookPageEvent {
  SaveNewBookPageEvent({required this.page});

  final BookPage page;

  @override
  List<Object?> get props => [page];
}

class AddBookPageEvent extends BookPageEvent {
  AddBookPageEvent({required this.page});

  final BookPage page;

  @override
  List<Object?> get props => [page];
}

class InitBookEvent extends BookPageEvent {
  InitBookEvent({required this.book});

  final Book book;
}

class NextPageEvent extends BookPageEvent {
  NextPageEvent({required this.pageIndex});

  final int pageIndex;
}

class PreviousPageEvent extends BookPageEvent {
  PreviousPageEvent({required this.pageIndex});

  final int pageIndex;
}

class AddNewBookChapterEvent extends BookPageEvent {
  AddNewBookChapterEvent({required this.chapter});

  final BookChapter chapter;
}

class BackToPageViewEvent extends BookPageEvent {
  BackToPageViewEvent();
}

class ChangeSelectedChapterEvent extends BookPageEvent {
  ChangeSelectedChapterEvent({required this.chapter});

  final BookChapter chapter;
}

class SaveBookChapterEvent extends BookPageEvent {
  SaveBookChapterEvent({required this.chapter});

  final BookChapter chapter;
}

class SaveEditedPageEvent extends BookPageEvent {
  SaveEditedPageEvent({required this.page});

  final BookPage page;
}

class UpdateBookPagesEvent extends BookPageEvent {
  UpdateBookPagesEvent({required this.page});

  final BookPage page;
}
