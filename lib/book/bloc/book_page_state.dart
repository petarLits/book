import 'dart:io';
import 'dart:math';

import 'package:book/book/book_page/book_page.dart';
import 'package:equatable/equatable.dart';

sealed class BookPageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitialState extends BookPageState {
  InitialState();
}

class BookPageImageAdded extends BookPageState {
  BookPageImageAdded({required this.image});

  final File? image;

  @override
  List<Object?> get props => [
        image,
        Random().nextInt(10000),
      ];
}

class BookPageImageDeleted extends BookPageState {
  BookPageImageDeleted();
}

class LoadingState extends BookPageState {
  LoadingState();
}

class LoadedState extends BookPageState {
  LoadedState();
}

class ErrorState extends BookPageState {
  ErrorState({required this.error});

  final Exception error;

  @override
  List<Object?> get props => [
        error,
        Random().nextInt(10000),
      ];
}

class BookPageImageUploaded extends BookPageState {
  BookPageImageUploaded({required this.page});

  final BookPage page;

  @override
  List<Object?> get props => [
        page,
        Random().nextInt(10000),
      ];
}

class NewBookPageSaved extends BookPageState {
  NewBookPageSaved({required this.page});

  final BookPage page;

  @override
  List<Object?> get props => [
        page,
        Random().nextInt(10000),
      ];
}

class AddBookPageState extends BookPageState {
  AddBookPageState({required this.page});

  final BookPage page;

  @override
  List<Object?> get props => [
        page,
        Random().nextInt(10000),
      ];
}
