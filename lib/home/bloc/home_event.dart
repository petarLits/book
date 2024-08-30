import 'dart:io';

import 'package:book/book/book.dart';
import 'package:equatable/equatable.dart';


sealed class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignOut extends HomeEvent {}

class UploadBook extends HomeEvent {

  UploadBook({required this.book});

  final Book book;

  @override
  List<Object?> get props => [book];
}

class SaveNewBook extends HomeEvent{
  SaveNewBook({required this.book});

  final Book book;

  @override
  List<Object?> get props => [book];
}

class AddBookImage extends HomeEvent{

  AddBookImage({required this.image});

  final File image;

  @override
  List<Object?> get props => [image];
}

class UploadBookImageAndGetUrl extends HomeEvent{

  UploadBookImageAndGetUrl({required this.book});

  final Book book;

  @override
  List<Object?> get props => [book];
}

class DeleteBookImage extends HomeEvent{

  DeleteBookImage();
}