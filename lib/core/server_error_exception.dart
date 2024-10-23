import 'package:book/core/constants.dart';

class ServerErrorException implements Exception{

  String get message => serverError;

  @override
  String toString() => serverError;

}