import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text('Sign in'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Form(
      child: Column(
        children: [Container()],
      ),
    );
  }
}
