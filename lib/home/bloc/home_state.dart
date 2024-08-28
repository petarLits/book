import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../book/book.dart';

sealed class HomeState extends Equatable{

  @override
  List<Object?> get props => [];
}


class InitialState extends HomeState{
  InitialState();
}

class SuccessfulSignOut extends HomeState{
  SuccessfulSignOut();
}

class ErrorState extends HomeState{

ErrorState({required this.error});

  final Exception error;

  @override
  List<Object?> get props => [error, Random().nextInt(10000)];
}

class AddingNewBook extends HomeState{
  @override
  List<Object?> get props => [Random().nextInt(10000)];
}

class SavedBook extends HomeState{
  SavedBook({required this.book});

  final Book book;
}