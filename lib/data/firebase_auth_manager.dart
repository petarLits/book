import 'package:book/app_user.dart';
import 'package:book/constants.dart';
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
        .timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });
    ;

    final currentUser = auth.currentUser;
    if (currentUser != null) {
      uId = currentUser.uid;
    }
    final userRef = db.collection('users').doc(uId);

    userRef.set(user.toJson()).timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });
  }

  Future<void> loginUser(String email, String password) async {
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });
  }

  Future<String?> getCurrentUserId() async {
    final result = await auth.currentUser?.uid;
    if (result != null) {
      return result;
    }
    return null;
  }

  Future<AppUser?> downloadCurrentUser() async {
    final result =
        await getCurrentUserId().timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });
    if (result != null) {
      final userRef = db.collection('users').doc(result);
      final snapShot =
          await userRef.get().timeout(Duration(seconds: 3), onTimeout: () {
        throw Exception(serverError);
      });
      if (snapShot.data() != null) {
        AppUser appUser = AppUser.fromJson(snapShot.data()!);
        return appUser;
      } else {
        return null;
      }
    }
    return null;
  }

  Future<void> signOut() async{
    await auth.signOut().timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception(serverError);
    });
  }
}
