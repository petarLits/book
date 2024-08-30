import 'dart:io';

import 'package:equatable/equatable.dart';

class BookPageImage extends Equatable {
  BookPageImage(
      {required this.width,
      required this.height,
      this.image,
      this.imageUrl,
      this.imagePath});

  int width;
  int height;
  File? image;
  String? imageUrl;
  String? imagePath;

  @override
  List<Object?> get props => [width, height, imagePath, imageUrl, imagePath];
}
