// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_chapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookChapter _$BookChapterFromJson(Map<String, dynamic> json) => BookChapter(
      number: (json['number'] as num).toInt(),
      title: json['title'] as String,
    );

Map<String, dynamic> _$BookChapterToJson(BookChapter instance) =>
    <String, dynamic>{
      'number': instance.number,
      'title': instance.title,
    };
