import 'package:book/app_user.dart';
import 'package:book/data/firebase_auth_manager.dart';

class AppUserSingleton {
  static AppUserSingleton? _instance;
  AppUser? _appUser;

  AppUserSingleton._internal() {}

  factory AppUserSingleton() {
    if (_instance == null) {
      _instance = AppUserSingleton._internal();
    }
    return _instance!;
  }

  static AppUserSingleton get instance => AppUserSingleton();

  Future<AppUser?> fetchCurrentUser() async {
    AppUser? result = await FirebaseAuthManager.instance.downloadCurrentUser();

    _appUser = result;

    return result;
  }

  AppUser? get appUser => _appUser;

  void clearAppUser() {
    _appUser = null;
  }
}
