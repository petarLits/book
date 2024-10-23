import 'dart:io';

import 'package:book/enums/image_aspect_ratio.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'book_page_image.g.dart';

@JsonSerializable()
class BookPageImage extends Equatable {
  BookPageImage({
    required this.width,
    required this.height,
    this.image,
    this.imageUrl,
    this.imagePath,
  });

  int width;
  int height;
  @JsonKey(includeFromJson: false, includeToJson: false)
  File? image;
  String? imageUrl;
  String? imagePath;

  @override
  List<Object?> get props => [
        width,
        height,
        imageUrl,
      ];

  String getFileName() {
    return image?.path.split('/').last ??
        imageUrl?.split('/').last ??
        'No Image';
  }

  ImageAspectRatio aspectRatio() {
    if (this.width / this.height < 1) {
      return ImageAspectRatio.portrait;
    } else {
      return ImageAspectRatio.landscapeOrSquare;
    }
  }

  factory BookPageImage.fromJson(Map<String, dynamic> json) =>
      _$BookPageImageFromJson(json);

  Map<String, dynamic> toJson() => _$BookPageImageToJson(this);
}
