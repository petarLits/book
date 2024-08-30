import 'package:book/book/book_page/book_page_image.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

class BookPage extends Equatable {
  BookPage({
    required this.text,
    required this.pageNumber,
    this.pageImage,
    this.imageUrl,
  });

  String text;
  int pageNumber;
  BookPageImage? pageImage;
  String? imageUrl;

  @override
  List<Object?> get props => [text, pageNumber, pageImage, imageUrl];
}
