import 'dart:io';

import 'package:book/enums/image_aspect_ratio.dart';
import 'package:equatable/equatable.dart';

class BookPageImage extends Equatable {
  BookPageImage({
    required this.width,
    required this.height,
    this.image,
    this.imageUrl,
  });

  int width;
  int height;
  File? image;
  String? imageUrl;

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
}
