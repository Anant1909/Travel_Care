import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get currentUser => null;

  Future<User?> signUpWithEmailAndPassword(String email, String password)async{

    try {
      // Ensure Firebase App Check is active
      final token = await FirebaseAppCheck.instance.getToken();
      if (kDebugMode) {
        print('App Check Token: $token');
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } catch (e) {
      if (kDebugMode) {
        print('Some error occurred: $e');
      }
      return null;
    }

  }
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

    Future<User?> signInWithEmailAndPassword(String email,String password,
) async {
  try {
    // Ensure Firebase App Check is active
    final token = await FirebaseAppCheck.instance.getToken();
    if (kDebugMode) {
      print('App Check Token: $token');
    }

    UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return credential.user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided.');
    } else {
      print('Error: ${e.message}');
    }
    return null;
  } catch (e) {
    print('Some error occurred: $e');
    return null;
  }
}

  }

