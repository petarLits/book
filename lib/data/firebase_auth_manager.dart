import 'package:book/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthManager {
  static final auth = FirebaseAuth.instance;
  static final db = FirebaseFirestore.instance;

  static Future<void> registerUser(AppUser user) async {
    late String uId;
    await auth
        .createUserWithEmailAndPassword(
            email: user.email, password: user.password)
        .timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception('Cant reach server');
    });
    ;

    final currentUser = auth.currentUser;
    if (currentUser != null) {
      uId = currentUser.uid;
    }
    final userRef = db.collection('users').doc(uId);

    userRef.set(user.toJson()).timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception('Cant reach server');
    });
  }

  static Future<void> loginUser(String email, String password) async {
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception('Cant reach server');
    });

  }
}
