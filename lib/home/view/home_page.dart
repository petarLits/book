import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  @override
  State<HomePage> createState() => _HomePageSate();


}

class _HomePageSate  extends State<HomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Title'),
      ),
    );
  }

}