import 'package:book/book/book_chapter/book_chapter.dart';
import 'package:book/book/book_page/book_page_image.dart';
import 'package:equatable/equatable.dart';

class BookPage extends Equatable {
  BookPage({
    required this.text,
    required this.pageNumber,
    this.pageImage,
    this.imageUrl,
    this.chapter,
  });

  String text;
  int pageNumber;
  BookPageImage? pageImage;
  String? imageUrl;
  BookChapter? chapter;

  @override
  List<Object?> get props => [text, pageNumber, pageImage, imageUrl, chapter];
}
