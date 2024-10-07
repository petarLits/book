import 'package:book/book/book_chapter/book_chapter.dart';
import 'package:book/book/book_page/book_page.dart';
import 'package:equatable/equatable.dart';

class BookData extends Equatable {
  BookData({required this.bookPages, required this.bookChapters});

  BookData.emptyData({
    this.bookPages = const [],
    this.bookChapters = const [],
  });

  List<BookPage> bookPages;
  List<BookChapter> bookChapters;

  @override
  List<Object?> get props => [bookPages];
}
