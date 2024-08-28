import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../book/book.dart';

sealed class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignOut extends HomeEvent {}

class AddNewBook extends HomeEvent {}

class SaveNewBook extends HomeEvent{
  SaveNewBook({required this.book});

  final Book book;
}