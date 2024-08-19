import 'package:book/app_colors.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
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
  bool passwordVisible = true;
  bool confirmPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text('Register'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _buildBody(),
    );
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
                        return 'Enter First Name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      firstName = value;
                    },
                    maxLength: 24,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name',
                    ),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Last Name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      lastName = value;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Last Name',
                    ),
                    maxLength: 24,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    onChanged: (value) {
                      emailValue = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter email';
                      } else if (validateEmail(emailValue) == false) {
                        return 'Invalid email input';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), labelText: 'Email'),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    onChanged: (value) {
                      passwordValue = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter password';
                      } else if (!value.contains(RegExp(r'[A-Z]'))) {
                        return "Password must contain at least one uppercase letter";
                      } else if (!value.contains(RegExp(r'[a-z]'))) {
                        return "Password must contain at least one lowercase letter";
                      } else if (!value.contains(RegExp(r'[0-9]'))) {
                        return "Password must contain at least one numeric character";
                      } else if (!value
                          .contains(RegExp(r'[!@#\$%^&*()<>?/|}{~:]'))) {
                        return "Password must contain at least one special character";
                      }
                      if (value.length < 8) {
                        return "Password must be at least 8 characters long";
                      } else {
                        return null;
                      }
                    },
                    maxLength: 16,
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            passwordVisible = !passwordVisible;
                            setState(() {});
                          },
                          icon: Icon(Icons.visibility),
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'Password'),
                    obscureText: passwordVisible,
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    onChanged: (value) {
                      confirmPasswordValue = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirm password';
                      } else if (value != passwordValue) {
                        return 'Passwords do not match';
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            confirmPasswordVisible = !confirmPasswordVisible;
                            setState(() {});
                          },
                          icon: Icon(Icons.visibility),
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'Confirm password'),
                    maxLength: 16,
                    obscureText: confirmPasswordVisible,
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Sign Up'),
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
