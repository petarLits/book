import 'package:flutter/material.dart';

class DialogUtils {

  static Future<void> showLoadingScreen(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator(),),
    );
  }
}
