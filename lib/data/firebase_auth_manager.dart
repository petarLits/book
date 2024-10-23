import 'dart:io';

import 'package:book/app_user.dart';
import 'package:book/core/constants.dart';
import 'package:book/core/server_error_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
    }
    final userRef = db.collection(usersCollection).doc(uId);

    await userRef
        .set(user.toJson())
        .timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
      throw ServerErrorException();
    });
    await signOut();
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
      final snapShot = await userRef
          .get()
          .timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
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
    await auth.signOut().timeout(Duration(seconds: kTimeoutInSeconds),
        onTimeout: () {
      throw ServerErrorException();
    });
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser;
    if (Platform.isIOS) {
      await GoogleSignIn().signOut();
      googleUser = await GoogleSignIn(
        clientId: signInClientId,
        scopes: [email],
      ).signIn().timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
        throw ServerErrorException();
      });
    } else {
      await GoogleSignIn().signOut();
      googleUser = await GoogleSignIn()
          .signIn()
          .timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
        throw ServerErrorException();
      });
    }

    final GoogleSignInAuthentication? googleAuth = await googleUser
        ?.authentication
        .timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
      throw ServerErrorException();
    });

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    final userCredential = await auth
        .signInWithCredential(credential)
        .timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
      throw ServerErrorException();
    });

    if(credential.providerId == googleProvider){
     await auth.currentUser!.unlink(googleProvider);
    }
    await auth.currentUser!.linkWithCredential(credential);

    return userCredential;
  }

  Future<void> addUserToDatabase(AppUser appUser) async {
    String? uId;
    final User? checkUser = auth.currentUser;
    if (checkUser != null) {
      uId = checkUser.uid;
      final credential = EmailAuthProvider.credential(
          email: appUser.email, password: appUser.password);
     await checkUser.linkWithCredential(credential);
    }
    final userRef = db.collection(usersCollection).doc(uId);
    await userRef
        .set(appUser.toJson())
        .timeout(Duration(seconds: kTimeoutInSeconds), onTimeout: () {
      throw ServerErrorException();
    });
    await signOut();
  }

  Future<UserCredential> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);
    return await auth.signInWithCredential(facebookAuthCredential);
  }

  Future<void> sendEmailVerification() async {
    User? user = auth.currentUser;
    if (!user!.emailVerified) {
      await auth.currentUser?.sendEmailVerification();
    }
  }
}
