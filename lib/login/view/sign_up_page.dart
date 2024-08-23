import 'package:book/app_colors.dart';
import 'package:book/app_user.dart';
import 'package:book/login/bloc/login_bloc.dart';
import 'package:book/login/bloc/login_event.dart';
import 'package:book/login/bloc/login_state.dart';
import 'package:book/utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUp extends StatefulWidget {
  const SignUp();

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  late String firstName;
  late String lastName;
  late String emailValue;
  late String passwordValue;
  late String confirmPasswordValue;
  bool passwordInvisible = false;
  bool confirmPasswordInvisible = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
        builder: (context, LoginState state) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: Text(AppLocalizations.of(context)!.register),
          backgroundColor: AppColors.primaryColor,
        ),
        body: _buildBody(),
      );
    }, listener: (context, state) {
      if (state is SuccessfulSignUp) {
        Navigator.pop(context);
        final snackBar = SnackBar(
          backgroundColor: AppColors.successfulSnackBar,
          content: Text(AppLocalizations.of(context)!.successfullyRegistered),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (state is SignUpErrorAuth) {
        final snackBarErrorAuth = SnackBar(
          backgroundColor: AppColors.errorSnackBar,
          content: Text(AppLocalizations.of(context)!.invalidEmail),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBarErrorAuth);
      } else if (state is ErrorState) {
        final snackBarError = SnackBar(
          backgroundColor: AppColors.errorSnackBar,
          content: Text(AppLocalizations.of(context)!.serverError),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBarError);
      }
    });
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.elliptical(60, 60),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              margin: EdgeInsets.only(right: 24, left: 24),
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emptyFirstName;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      firstName = value;
                    },
                    maxLength: 24,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.firstName,
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emptyLastName;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      lastName = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.lastName,
                    ),
                    maxLength: 24,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      emailValue = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.emptyEmail;
                      } else if (!ValidationUtils.validateEmail(emailValue)) {
                        return AppLocalizations.of(context)!.emailError;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.email),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      passwordValue = value;
                    },
                    validator: (value) {
                      return ValidationUtils.validatePassword(context, value);
                    },
                    maxLength: 16,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            passwordInvisible = !passwordInvisible;
                            setState(() {});
                          },
                          icon: Icon(Icons.visibility),
                        ),
                        border: OutlineInputBorder(),
                        labelText: AppLocalizations.of(context)!.password),
                    obscureText: !passwordInvisible,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      confirmPasswordValue = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.confirmPassword;
                      } else if (value != passwordValue) {
                        return AppLocalizations.of(context)!
                            .confirmPasswordError;
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            confirmPasswordInvisible =
                                !confirmPasswordInvisible;
                            setState(() {});
                          },
                          icon: Icon(Icons.visibility),
                        ),
                        border: OutlineInputBorder(),
                        labelText:
                            AppLocalizations.of(context)!.confirmPassword),
                    maxLength: 16,
                    obscureText: !confirmPasswordInvisible,
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            AppUser newUser = AppUser(
                                firstName: firstName,
                                lastName: lastName,
                                email: emailValue,
                                password: passwordValue);

                            context
                                .read<LoginBloc>()
                                .add(SignUpEvent(user: newUser));
                          }
                        },
                        child:
                            Text(AppLocalizations.of(context)!.registerButton),
                        style: ElevatedButton.styleFrom(
                          fixedSize: Size(200, 50),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
