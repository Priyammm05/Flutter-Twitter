// ignore_for_file: avoid_print, unused_local_variable, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_clone/models/user.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;

  UserModel? userFromFirebase(User? user) {
    return user != null
        ? UserModel(
            id: user.uid,
          )
        : null;
  }

  Stream<UserModel?> get user {
    return auth.authStateChanges().map(userFromFirebase);
  }

  Future signUp(email, password) async {
    try {
      UserCredential user = await auth.createUserWithEmailAndPassword(
        email: email as String,
        password: password as String,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.user?.uid)
          .set({
        'name': email,
        'email': email,
      });

      userFromFirebase(user.user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future signIn(email, password) async {
    try {
      UserCredential user = await auth.signInWithEmailAndPassword(
        email: email as String,
        password: password as String,
      );
    } catch (e) {
      print(e);
    }
  }

  Future signOut() async {
    try {
      return await auth.signOut();
    } catch (e) {
      print(e);
      return null;
    }
  }
}
