import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app_firebase/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app_firebase/features/auth/domain/repository/auth_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthRepo implements AuthRepo {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;

      if (user != null) {

        DocumentSnapshot userDoc = await _fireStore
            .collection('users')
            .doc(user.uid)
            .get();

        return AppUser(
          uid: user.uid,
          email: user.email ?? '',
          name: userDoc['name'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error in getCurrentUser: $e');
      return null;
    }
  }

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _fireStore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      final user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: userDoc['name'],
      );

      return user;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw Exception('Incorrect login information.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      await _fireStore.collection("users").doc(user.uid).set(user.toJson());
      return user;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('This email is already registered.');
      } else if (e.code == 'weak-password') {
        throw Exception('The password is too weak.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else {
        throw Exception('Registration error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error in logout: $e');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    try {
      // Re-authenticate before updating password
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Current password is incorrect.');
      } else if (e.code == 'weak-password') {
        throw Exception('The new password is too weak.');
      } else {
        throw Exception('Password change failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'invalid-email') {
        throw Exception('The email address is not valid.');
      } else {
        throw Exception('Failed to send password reset email: ${e.message}');
      }
    }
  }
}