import 'package:book/app_colors.dart';
import 'package:book/app_user.dart';
import 'package:book/core/constants.dart';
import 'package:book/login/bloc/login_bloc.dart';
import 'package:book/login/bloc/login_event.dart';
import 'package:book/login/bloc/login_state.dart';
import 'package:book/login/widgets/custom_text_form_field.dart';
import 'package:book/utils/snackbar_utils.dart';
import 'package:book/utils/validation_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateUserWithProvider extends StatefulWidget {
  CreateUserWithProvider({required this.credential});

  final UserCredential credential;

  @override
  State<CreateUserWithProvider> createState() => _CreateUserWithProviderState();
}

class _CreateUserWithProviderState extends State<CreateUserWithProvider> {
  late String firstName;
  late String lastName;
  late String passwordValue;
  late String confirmPasswordValue;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    firstName = widget.credential.user!.displayName!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(listener: (context, state) {
      if (state is SuccessfulSignUp) {
        Navigator.pop(context);
        SnackBarUtils.showSnackBar(
          color: AppColors.successfulSnackBar,
          content: AppLocalizations.of(context)!.successfullyRegistered,
          context: context,
        );
      }
    }, builder: (context, LoginState state) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
        ),
        body: Form(
          key: _formKey,
          child: Container(
            margin: EdgeInsets.all(pageMargin),
            child: Column(
              children: [
                CustomTextFormField(
                  initialValue: firstName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyFirstName;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    firstName = value;
                  },
                  maxLength: nameMaxLength,
                  isNonPasswordField: true,
                  labelText: AppLocalizations.of(context)!.firstName,
                ),
                SizedBox(height: 30),
                CustomTextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyLastName;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    lastName = value;
                  },
                  maxLength: nameMaxLength,
                  isNonPasswordField: true,
                  labelText: AppLocalizations.of(context)!.lastName,
                ),
                SizedBox(
                  height: 30,
                ),
                CustomTextFormField(
                  onChanged: (value) {
                    passwordValue = value;
                  },
                  validator: (value) {
                    return ValidationUtils.validatePassword(context, value);
                  },
                  maxLength: passwordMaxLength,
                  isNonPasswordField: false,
                  labelText: AppLocalizations.of(context)!.password,
                ),
                SizedBox(height: 30),
                CustomTextFormField(
                  onChanged: (value) {
                    confirmPasswordValue = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.confirmPassword;
                    } else if (value != passwordValue) {
                      return AppLocalizations.of(context)!.confirmPasswordError;
                    } else {
                      return null;
                    }
                  },
                  isNonPasswordField: false,
                  labelText: AppLocalizations.of(context)!.confirmPassword,
                  maxLength: passwordMaxLength,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          if(_formKey.currentState!.validate()) {
                            AppUser user = AppUser(
                                firstName: firstName,
                                lastName: lastName,
                                email: widget.credential.additionalUserInfo!.profile!["email"],
                                password: passwordValue);
                            context
                                .read<LoginBloc>()
                                .add(SignUpWithProviderEvent(user: user));
                          }
                        },
                        child: Text(AppLocalizations.of(context)!.saveButton))
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
