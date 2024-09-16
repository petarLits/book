import 'package:book/book/book_chapter/book_chapter.dart';
import 'package:book/book/book_page/book_page_image.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_page.g.dart';

@JsonSerializable()
class BookPage extends Equatable {
  BookPage({
    required this.text,
    required this.pageNumber,
    this.pageImage,
    this.chapter,
  });

  String text;
  int pageNumber;
  BookPageImage? pageImage;
  BookChapter? chapter;

  @override
  List<Object?> get props => [
        text,
        pageNumber,
        pageImage,
        chapter,
      ];

  factory BookPage.fromJson(Map<String, dynamic> json) =>
      _$BookPageFromJson(json);

  Map<String, dynamic> toJson() => _$BookPageToJson(this);
}
