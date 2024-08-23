import 'package:book/app_routes.dart';
import 'package:book/app_user_singleton.dart';
import 'package:book/data/firebase_auth_manager.dart';
import 'package:book/utils/future_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageSate();
}

class _HomePageSate extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () async {
            final message = await FutureUtils.executeFutureWithLoader(
                context, FirebaseAuthManager.instance.signOut());
            if (message != null) {
              AppUserSingleton.instance.clearAppUser();
              Navigator.pushReplacementNamed(context, loginRoute);
            }
          },
          icon: Icon(Icons.exit_to_app),
        ),
        title: Text(AppLocalizations.of(context)!.welcome),
      ),
    );
  }
}
