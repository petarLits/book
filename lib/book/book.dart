import 'dart:io';

import 'package:book/book/book_data.dart';
import 'package:equatable/equatable.dart';

class Book extends Equatable {
  Book({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.docId,
    this.bookData,
  });

  Book.emptyBook({
    this.title = '',
    this.author = '',
    this.imageUrl = '',
    this.docId = '',
  });

  String title;
  String author;
  File? image;
  String imageUrl;
  BookData? bookData;
  String docId;

  factory Book.fromJson(Map<String, dynamic> data, String docId) {
    return Book(
        author: data['author'],
        title: data['title'],
        imageUrl: data['image'],
        docId: docId);
  }

  Map<String, dynamic> toJson() {
    return {'author': author, 'title': title, 'image': imageUrl};
  }

  @override
  List<Object?> get props => [
        title,
        author,
        imageUrl,
        bookData,
        docId,
      ];
}
