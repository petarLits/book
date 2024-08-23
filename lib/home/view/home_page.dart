import 'package:book/app_colors.dart';
import 'package:book/app_routes.dart';
import 'package:book/app_user_singleton.dart';
import 'package:book/data/firebase_auth_manager.dart';
import 'package:book/home/bloc/home_bloc.dart';
import 'package:book/home/bloc/home_event.dart';
import 'package:book/home/bloc/home_state.dart';
import 'package:book/utils/future_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageSate();
}

class _HomePageSate extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
        builder: (context, HomeState state) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
             context.read<HomeBloc>().add(SignOut());
            },
            icon: Icon(Icons.exit_to_app),
          ),
          title: Text(AppLocalizations.of(context)!.welcome),
        ),
      );
    }, listener: (context, state) {
      if (state is SuccessfulSignOut) {
        Navigator.pushReplacementNamed(context, loginRoute);
      } else if (state is ErrorState) {
        final snackBar = SnackBar(
          backgroundColor: AppColors.errorSnackBar,
          content: Text(
            AppLocalizations.of(context)!.serverError,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }
}
