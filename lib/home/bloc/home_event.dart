import 'package:equatable/equatable.dart';

sealed class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignOut extends HomeEvent {}

class AddNewBook extends HomeEvent {}

class SaveNewBook extends HomeEvent {
  SaveNewBook({
    required this.author,
    required this.title,
    required this.imageUrl,
  });

  final String author;
  final String title;
  final String imageUrl;
}
