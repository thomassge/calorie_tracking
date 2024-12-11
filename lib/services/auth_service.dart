import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerWithEmailAndPassword(
      String email,
      String password,
      String name,
      String surname,
      int height,
      double weight,
      String goal) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Die uid als Dokument-ID in Firestore verwenden
      final uid = userCredential.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'surname': surname,
        'height': height,
        'weight': weight,
        'goal': goal
        //profile settings habe ich leer gelassen, weil noch explizit definiert werden muss, was hier rein soll &
        //ich nicht weiß, ob das hier überhaupt nötig ist oder es schlauer wäre das nach dem ersten Login zu machen
        //'profil_setttings': {},
      });
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Login failed: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  //darf nur implementiert werden, wenn der Nutzer eingeloggt ist
  Future<void> changePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      print('Password changed successfully');
    } catch (e) {
      print('Password change failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent');
    } catch (e) {
      print('Password reset failed: $e');
    }
  }

  //darf nur implementiert werden, wenn der Nutzer eingeloggt ist
  Future<void> changeEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
      print('Email changed successfully');
    } catch (e) {
      print('Email change failed: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).delete();
      await _auth.currentUser?.delete();
      print('Account deleted successfully');
    } catch (e) {
      print('Account deletion failed: $e');
    }
  }
}