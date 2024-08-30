import 'dart:io';
import 'dart:math';

import 'package:book/book/book.dart';
import 'package:equatable/equatable.dart';

sealed class HomeState extends Equatable {

  @override
  List<Object?> get props => [];
}

class InitialState extends HomeState {
  InitialState();
}

class SuccessfulSignOut extends HomeState {
  SuccessfulSignOut();
}

class ErrorState extends HomeState {

  ErrorState({required this.error});

  final Exception error;

  @override
  List<Object?> get props => [error, Random().nextInt(10000)];
}

class UploadedBookState extends HomeState {

  UploadedBookState({required this.book});

  final Book book;

  @override
  List<Object?> get props => [book];
}

class SavedBookState extends HomeState {

  SavedBookState({required this.book});

  final Book book;

  @override
  List<Object?> get props => [book, Random().nextInt(10000)];
}

class AddBookImageState extends HomeState {

  AddBookImageState({required this.image});

  final File image;
}

class UploadedBookImageAndUrlGotState extends HomeState {

  UploadedBookImageAndUrlGotState({required this.book});

  final Book book;

  @override
  List<Object?> get props => [book];
}

class DeletedBookImage extends HomeState {
  DeletedBookImage();

  @override
  List<Object?> get props => [Random().nextInt(10000)];
}

class LoadingState extends HomeState {
  LoadingState();

  @override
  List<Object?> get props => [Random().nextInt(10000)];
}

class LoadedState extends HomeState {
  LoadedState();

  @override
  List<Object?> get props => [Random().nextInt(10000)];
}
