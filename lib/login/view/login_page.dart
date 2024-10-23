import 'package:book/app_colors.dart';
import 'package:book/app_routes.dart';
import 'package:book/app_text_styles.dart';
import 'package:book/core/constants.dart';
import 'package:book/login/bloc/login_bloc.dart';
import 'package:book/login/bloc/login_state.dart';
import 'package:book/login/widgets/custom_text_form_field.dart';
import 'package:book/utils/dialog_utils.dart';
import 'package:book/utils/snackbar_utils.dart';
import 'package:book/utils/validation_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:open_mail_app/open_mail_app.dart';

import '../bloc/login_event.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late String emailValue;
  late String passwordValue;
  bool passwordInvisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) async {
      if (state is SuccessfulLogin) {
        Navigator.pushReplacementNamed(context, homeRoute);
      } else if (state is ErrorAuthState) {
        SnackBarUtils.showSnackBar(
          color: AppColors.errorSnackBar,
          content: AppLocalizations.of(context)!.invalidCredentials,
          context: context,
        );
      } else if (state is ErrorState) {
        SnackBarUtils.showSnackBar(
          color: AppColors.errorSnackBar,
          content: AppLocalizations.of(context)!.serverError,
          context: context,
        );
      } else if (state is LoadingState) {
        DialogUtils.showLoadingScreen(context);
      } else if (state is LoadedState) {
        Navigator.pop(context);
      } else if (state is SignInWithGoogleState) {
        context
            .read<LoginBloc>()
            .add(CreateUserWithGoogleEvent(credential: state.credential));
      } else if (state is CreateUserWithGoogleState) {
        Navigator.pushNamed(context, signUpWithProvider,
            arguments: state.credential);
      } else if (state is SignInWithFacebookState) {
        context
            .read<LoginBloc>()
            .add(CreateUserWithFacebookEvent(credential: state.credential));
      } else if (state is CreateUserWithFacebookState) {
        Navigator.pushNamed(context, signUpWithProvider,
            arguments: state.credential);
      } else if (state is SignInWithDifferentProviderState) {
        SnackBarUtils.showSnackBar(
            color: Colors.orangeAccent,
            content: AppLocalizations.of(context)!.accountExist,
            context: context);
      } else if (state is VerifyEmailState) {
        final result = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            content: Text(AppLocalizations.of(context)!.verifyEmail),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text(AppLocalizations.of(context)!.goToEmail),
              ),
            ],
          ),
        );
        if (result) {
          context.read<LoginBloc>().add(OpenMailAppEvent());
        }
      } else if (state is CanNotOpenMailState) {
        SnackBarUtils.showSnackBar(
            color: AppColors.errorSnackBar,
            content: AppLocalizations.of(context)!.canNotOpenMail,
            context: context);
      } else if (state is MailAppDidNotOpenState) {
        showDialog(
            context: context,
            builder: (context) =>
                MailAppPickerDialog(mailApps: state.mailApps.options));
      }
    }, builder: (context, LoginState state) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primaryColor,
          title: Text(
            AppLocalizations.of(context)!.loginTitle,
            style: AppTextStyles.smallerBlackTitle(),
          ),
        ),
        body: _buildBody(),
      );
    });
  }

  Widget _buildBody() {
    return Form(
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
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
            ),
          ),
          SizedBox(height: 40),
          Container(
            margin: EdgeInsets.only(left: 24, right: 24),
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.welcome,
                  style: AppTextStyles.smallerBlackTitle(),
                ),
                Text(
                  AppLocalizations.of(context)!.loginSubtitle,
                  style: AppTextStyles.subtitle(),
                ),
                SizedBox(height: 30),
                CustomTextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyEmail;
                    } else if (ValidationUtils.validateEmail(value) == false) {
                      return AppLocalizations.of(context)!.emailError;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    emailValue = value;
                  },
                  isNonPasswordField: true,
                  labelText: AppLocalizations.of(context)!.email,
                  maxLength: emailMaxLength,
                ),
                SizedBox(
                  height: 20,
                ),
                CustomTextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyPassword;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    passwordValue = value;
                  },
                  isNonPasswordField: false,
                  labelText: AppLocalizations.of(context)!.password,
                  maxLength: passwordMaxLength,
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<LoginBloc>().add(
                                Login(
                                  email: emailValue,
                                  password: passwordValue,
                                ),
                              );
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.loginButton),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(200, 50),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          signUpRoute,
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.signUpButton,
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.read<LoginBloc>().add(SignInWithGoogleEvent());
                      },
                      icon: Image.asset(
                        'assets/googleLogo.webp',
                        height: iconSize,
                        width: iconSize,
                      ),
                    ),
                    IconButton(
                        onPressed: () async {
                          context
                              .read<LoginBloc>()
                              .add(SignInWithFacebookEvent());
                        },
                        icon: Icon(Icons.facebook)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
