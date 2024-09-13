// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_page_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookPageImage _$BookPageImageFromJson(Map<String, dynamic> json) =>
    BookPageImage(
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      imageUrl: json['imageUrl'] as String?,
      imagePath: json['imagePath'] as String?,
    );

Map<String, dynamic> _$BookPageImageToJson(BookPageImage instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'imageUrl': instance.imageUrl,
      'imagePath': instance.imagePath,
    };
