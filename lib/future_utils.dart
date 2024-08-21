import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FutureUtils {

  static Future<dynamic> executeFutureWithLoader(
      BuildContext context, Future<dynamic> task) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(
        child: CupertinoActivityIndicator(),
      ),
    );
    try {
      final result = await task;
      return result ?? true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return null;
    } finally {
      Navigator.pop(context);
    }
  }
}
