import 'package:book/core/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ValidationUtils {
  static final emailRegex =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  static final uppercaseRegex = r'[A-Z]';
  static final lowercaseRegex = r'[a-z]';
  static final numericRegex = r'[0-9]';
  static final specialCharacterRegex = r'[!@#\$%^&*()<>?/|}{~:]';

  static bool validateEmail(String emailValue) {
    if (RegExp(emailRegex).hasMatch(emailValue)) {
      return true;
    } else {
      return false;
    }
  }

  static String? validatePassword(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emptyPassword;
    } else if (!value.contains(RegExp(uppercaseRegex))) {
      return AppLocalizations.of(context)!.passwordUppercaseError;
    } else if (!value.contains(RegExp(lowercaseRegex))) {
      return AppLocalizations.of(context)!.passwordLowercaseError;
    } else if (!value.contains(RegExp(numericRegex))) {
      return AppLocalizations.of(context)!.passwordNumericError;
    } else if (!value.contains(RegExp(specialCharacterRegex))) {
      return AppLocalizations.of(context)!.passwordSpecialCharacterError;
    }
    if (value.length < passwordMinLength) {
      return AppLocalizations.of(context)!.passwordLengthError;
    } else {
      return null;
    }
  }
}
