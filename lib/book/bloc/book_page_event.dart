import 'dart:io';
import 'dart:math';

import 'package:book/book/book_page/book_page.dart';
import 'package:equatable/equatable.dart';

sealed class BookPageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddBookPageImage extends BookPageEvent {
  AddBookPageImage({required this.image});

  final File? image;

  @override
  List<Object?> get props => [image];
}

class DeleteBookPageImage extends BookPageEvent {
  DeleteBookPageImage();
}

class SaveNewBookPage extends BookPageEvent {
  SaveNewBookPage({required this.page});

  final BookPage page;

  @override
  List<Object?> get props => [page];
}

class AddBookPage extends BookPageEvent {
  AddBookPage({required this.page});

  final BookPage page;

  @override
  List<Object?> get props => [page];
}


