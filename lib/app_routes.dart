import 'package:book/home/view/add_new_book.dart';
import 'package:book/home/view/home_page.dart';
import 'package:book/login/view/login_page.dart';
import 'package:flutter/material.dart';

import 'login/view/sign_up_page.dart';

const String homeRoute = '/';
const String loginRoute = '/Login';
const String signUpRoute = '/SignUp';
const String addNewBookRoute = '/AddNewBook';

class AppRoutes {

  static Route<dynamic>? onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return _materialRoute(
          HomePage(),
        );
      case loginRoute:
        return _materialRoute(
           LoginPage(),
        );

      case signUpRoute:
        return _materialRoute(
          SignUp(),
        );
      case addNewBookRoute:
        return _materialRoute(AddNewBook());
      default:
        return null;
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
