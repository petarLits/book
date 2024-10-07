import 'package:book/app_routes.dart';
import 'package:book/app_user_singleton.dart';
import 'package:book/core/constants.dart';
import 'package:book/home/bloc/home_bloc.dart';
import 'package:book/login/bloc/login_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

import 'book/book.dart';
import 'book/book_page/bloc/book_page_bloc.dart';
import 'data/firebase_db_manager.dart';
import 'firebase_options.dart';



GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Permission.notification.request();
  await AppUserSingleton.instance.fetchCurrentUser();
  FirebaseMessaging.instance.getInitialMessage().then((message) async {
    await _onInitialMessage(message);
  });
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    await _onMessageOpenedApp(message);
  });
  runApp(const MyApp());
}

Future<void> _onMessageOpenedApp(RemoteMessage message) async {
  if (message.notification != null) {
    Map<String, dynamic> data = message.data;

    int index = 0;
    if (data['action'] == messagePageAction) {
      if (data['index'] != null) {
        index = int.parse(data['index']);
      }

      final iD = data['bookId'];

      Book book = await FirebaseDbManager.instance.downloadBook(iD);
      Navigator.pushNamedAndRemoveUntil<dynamic>(
        navigatorKey.currentState!.context,
        bookPageRoute,
        arguments: <String, dynamic>{
          "book": book,
          "pageIndex": index,
        },
        (route) => route.isFirst,
      );
    }
  }
}

Future<void> _onInitialMessage(RemoteMessage? message) async {
  if (message != null) {
    Map<String, dynamic> data = message.data;

    int index = 0;
    if (data['action'] == messagePageAction) {
      if (data['index'] != null) {
        index = int.parse(data['index']);
      }

      final iD = data['bookId'];

      Book book = await FirebaseDbManager.instance.downloadBook(iD);
      Navigator.pushNamed<dynamic>(
        navigatorKey.currentState!.context,
        bookPageRoute,
        arguments: <String, dynamic>{
          "book": book,
          "pageIndex": index,
        },
      );
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
          BlocProvider<HomeBloc>(create: (context) => HomeBloc()),
          BlocProvider<BookPageBloc>(create: (context) => BookPageBloc()),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          onGenerateRoute: AppRoutes.onGenerateRoutes,
          initialRoute: AppUserSingleton.instance.appUser != null
              ? homeRoute
              : loginRoute,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
        ));
  }
}
