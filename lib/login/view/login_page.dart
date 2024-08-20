import 'package:book/app_colors.dart';
import 'package:book/home/view/home_page.dart';
import 'package:book/login/view/sign_up_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
        title: Text(AppLocalizations.of(context)!.loginTitle),
      ),
      body: _buildBody(),
    );
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
                Text(AppLocalizations.of(context)!.welcome),
                Text(AppLocalizations.of(context)!.loginSubtitle),
                SizedBox(height: 30),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyEmail;
                    } else if (validateEmail(value) == false) {
                      return AppLocalizations.of(context)!.emailError;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    emailValue = value;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: AppLocalizations.of(context)!.email,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.emptyPassword;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    passwordValue = value;
                  },
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
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        }
                      },
                      child:
                          Text(AppLocalizations.of(context)!.loginButton),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUp(),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.signUpButton,
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool validateEmail(String emailValue) {
    final emailRegex =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    if (RegExp(emailRegex).hasMatch(emailValue)) {
      return true;
    } else {
      return false;
    }
  }
}
