import 'package:book/app_user.dart';
import 'package:book/core/constants.dart';
import 'package:book/core/server_error_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthManager {
  static FirebaseAuthManager? _instance;
  late FirebaseAuth auth;
  late FirebaseFirestore db;

  FirebaseAuthManager._internal() {
    auth = FirebaseAuth.instance;
    db = FirebaseFirestore.instance;
  }

  static FirebaseAuthManager get instance => FirebaseAuthManager();

  factory FirebaseAuthManager() {
    if (_instance == null) {
      _instance = FirebaseAuthManager._internal();
    }
    return _instance!;
  }

  Future<void> registerUser(AppUser user) async {
    late String uId;
    await auth
        .createUserWithEmailAndPassword(
            email: user.email, password: user.password)
        .timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
      throw ServerErrorException();
    });
    ;

    final currentUser = auth.currentUser;
    if (currentUser != null) {
      uId = currentUser.uid;
      await FirebaseAuthManager.instance.signOut();
    }
    final userRef = db.collection(usersCollection).doc(uId);

    userRef.set(user.toJson()).timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
      throw ServerErrorException();
    });
  }

  Future<void> loginUser(String email, String password) async {
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
      throw ServerErrorException();
    });
  }

  String? get currentUserId => auth.currentUser?.uid;

  Future<AppUser?> downloadCurrentUser() async {
    if (currentUserId != null) {
      final userRef = db.collection(usersCollection).doc(currentUserId);
      final snapShot =
          await userRef.get().timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
        throw ServerErrorException();
      });
      if (snapShot.data() != null) {
        AppUser appUser = AppUser.fromJson(snapShot.data()!);
        return appUser;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<void> signOut() async {
    await auth.signOut().timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
      throw ServerErrorException();
    });
  }
}
