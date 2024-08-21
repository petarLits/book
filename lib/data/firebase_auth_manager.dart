import 'package:book/app_user.dart';
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

  factory FirebaseAuthManager(){
    if (_instance == null){
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

  Future<void> loginUser(String email, String password) async {
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .timeout(Duration(seconds: 3), onTimeout: () {
      throw Exception('Cant reach server');
    });
  }
}
