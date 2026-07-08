import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get user;
  Future<UserCredential> signUpWithEmailAndPassword({required String email, required String password});
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password});
  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail({required String email});
}
