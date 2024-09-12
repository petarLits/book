import 'package:book/app_routes.dart';
import 'package:book/app_user_singleton.dart';
import 'package:book/home/bloc/home_bloc.dart';
import 'package:book/login/bloc/login_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'book/book_page/bloc/book_page_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AppUserSingleton.instance.fetchCurrentUser();
  runApp(const MyApp());
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
