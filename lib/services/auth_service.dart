import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> registerWithEmailAndPassword(
      String email, String password, String name, String surname, int height, double weight, String goal) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'surname': surname,
        'height': height,
        'weight': weight,
        'goal': goal,
        'dietType': 'Standard',
      });

      // Sende Verifizierungs-E-Mail
      await sendEmailVerification();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}');
      throw e;
    } catch (e) {
      print('Allgemeiner Fehler: $e');
      throw e;
    }
  }



  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'E-Mail-Adresse ist nicht verifiziert. Bitte überprüfen Sie Ihr Postfach.',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      print('Login fehlgeschlagen: ${e.code}');
      throw e;
    } catch (e) {
      print('Allgemeiner Fehler beim Login: $e');
      throw e;
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

  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        print('Verifizierungsmail gesendet.');
      } else {
        print('Benutzer ist null oder bereits verifiziert.');
      }
    } catch (e) {
      print('Fehler beim Senden der Verifizierungsmail: $e');
      throw e; // Weiterreichen des Fehlers, falls nötig
    }
  }


}