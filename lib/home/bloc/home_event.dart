import 'dart:io';

import 'package:book/book/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignOut extends HomeEvent {}

class UploadBook extends HomeEvent {
  UploadBook({
    required this.book,
    required this.messageTitle,
    required this.messageBody,
  });

  final Book book;
  final String messageTitle;
  final String messageBody;

  @override
  List<Object?> get props => [
        book,
        messageTitle,
        messageBody,
      ];
}

class SaveNewBook extends HomeEvent {
  SaveNewBook({required this.book});

  final Book book;

  @override
  List<Object?> get props => [book];
}

class AddBookImage extends HomeEvent {
  AddBookImage({required this.image});

  final File image;

  @override
  List<Object?> get props => [image];
}

class UploadBookImageAndGetUrl extends HomeEvent {
  UploadBookImageAndGetUrl({required this.book});

  final Book book;

  @override
  List<Object?> get props => [book];
}

class DeleteBookImage extends HomeEvent {}

class DownloadBooksEvent extends HomeEvent {}

class GetBooksEvent extends HomeEvent {
  GetBooksEvent({required this.querySnapshot});

  final QuerySnapshot<Map<String, dynamic>> querySnapshot;

  @override
  List<Object?> get props => [querySnapshot];
}
