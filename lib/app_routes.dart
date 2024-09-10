import 'package:book/book/book.dart';
import 'package:book/book/book_page/book_page.dart';
import 'package:book/book/book_page/book_page_view.dart';
import 'package:book/book/book_page/new_book_page.dart';
import 'package:book/home/view/add_new_book.dart';
import 'package:book/home/view/home_page.dart';
import 'package:book/login/view/login_page.dart';
import 'package:flutter/material.dart';

import 'login/view/sign_up_page.dart';

const String homeRoute = '/';
const String loginRoute = '/Login';
const String signUpRoute = '/SignUp';
const String addNewBookRoute = '/AddNewBook';
const String bookPageRoute = "/BookPageView";
const String newPageRoute = "/NewBookPage";

class AppRoutes {
  static Route<dynamic>? onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return _materialRoute(HomePage());
      case loginRoute:
        return _materialRoute(LoginPage());

      case signUpRoute:
        return _materialRoute(SignUp());
      case addNewBookRoute:
        return _materialRoute(AddNewBook(newBook: settings.arguments as Book));
      case bookPageRoute:
        return _materialRoute(BookPageView(book: settings.arguments as Book));
      case newPageRoute:
        return _materialRoute(NewBookPage(
          newPage: (settings.arguments as Map<String, dynamic>)['newPage']
              as BookPage,
          bookId:
              (settings.arguments as Map<String, dynamic>)['bookId'] as String,
        ));
      default:
        return null;
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
