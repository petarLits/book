import 'package:book/home/view/home_page.dart';
import 'package:book/login/bloc/login_bloc.dart';
import 'package:book/login/view/login_page.dart';
import 'package:flutter/material.dart';
import 'login/view/sign_up_page.dart';

const String HomeRoute = '/';
const String LoginRoute = '/Login';
const String SignUpRoute = '/SignUp';

class AppRoutes {
  static Route<dynamic>? onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case HomeRoute:
        return _materialRoute(
          HomePage(),
        );
      case LoginRoute:
        return _materialRoute(
          LoginPage(),
        );
      case SignUpRoute:
        return _materialRoute(
          SignUp(bloc: settings.arguments as LoginBloc),
        );
    }
    return null;
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
