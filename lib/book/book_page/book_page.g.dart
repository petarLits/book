// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookPage _$BookPageFromJson(Map<String, dynamic> json) => BookPage(
      text: json['text'] as String,
      pageNumber: (json['pageNumber'] as num).toInt(),
      pageImage: json['pageImage'] == null
          ? null
          : BookPageImage.fromJson(json['pageImage'] as Map<String, dynamic>),
      chapter: json['chapter'] == null
          ? null
          : BookChapter.fromJson(json['chapter'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookPageToJson(BookPage instance) => <String, dynamic>{
      'text': instance.text,
      'pageNumber': instance.pageNumber,
      'pageImage': instance.pageImage?.toJson(),
      'chapter': instance.chapter!.toJson(),
    };
