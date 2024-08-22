import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class ValidationUtils {

  static bool validateEmail(String emailValue) {
    final emailRegex =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    if (RegExp(emailRegex).hasMatch(emailValue)) {
      return true;
    } else {
      return false;
    }
  }

  static String? validatePassword(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emptyPassword;
    } else if (!value.contains(RegExp(r'[A-Z]'))) {
      return AppLocalizations.of(context)!
          .passwordUppercaseError;
    } else if (!value.contains(RegExp(r'[a-z]'))) {
      return AppLocalizations.of(context)!
          .passwordLowercaseError;
    } else if (!value.contains(RegExp(r'[0-9]'))) {
      return AppLocalizations.of(context)!
          .passwordNumericError;
    } else if (!value
        .contains(RegExp(r'[!@#\$%^&*()<>?/|}{~:]'))) {
      return AppLocalizations.of(context)!
          .passwordSpecialCharacterError;
    }
    if (value.length < 8) {
      return AppLocalizations.of(context)!
          .passwordLengthError;
    } else {
      return null;
    }
  }
}
