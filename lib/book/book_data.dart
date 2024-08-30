import 'package:book/book/book_page/book_page.dart';
import 'package:equatable/equatable.dart';

class BookData extends Equatable {

  BookData({required this.bookPages});

  List<BookPage> bookPages;

  @override
  List<Object?> get props => [bookPages];
}
