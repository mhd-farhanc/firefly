import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Listen to user changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // SIGN IN (Updated to match Login Screen)
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred";
    }
  }

  // SIGN UP (Updated to match Login Screen)
  Future<String?> signUp(String email, String password, String username) async {
    try {
      // 1. Create user in Firebase Auth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Save their username in Firestore
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "An unknown error occurred";
    }
  }

  // LOG OUT
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
