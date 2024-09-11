import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_chapter.g.dart';

@JsonSerializable()
class BookChapter extends Equatable {
  BookChapter({
    required this.number,
    required this.title,
  });

  int number;
  String title;

  @override
  List<Object?> get props => [
        number,
        title,
      ];

  factory BookChapter.fromJson(Map<String, dynamic> json) =>
      _$BookChapterFromJson(json);

  Map<String, dynamic> toJson() => _$BookChapterToJson(this);
}


