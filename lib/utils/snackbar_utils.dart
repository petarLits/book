import 'package:flutter/material.dart';

class SnackBarUtils {
  static void showSnackBar({
    required Color color,
    required String content,
    required BuildContext context,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          content,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
