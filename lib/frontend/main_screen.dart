import 'package:flutter/material.dart';
//import 'package:inf_proj_flutter/Frontend/edit_profile_screen.dart';
//import 'package:inf_proj_flutter/Frontend/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';
import 'login.dart';

class MainScreen extends StatelessWidget {
  final AuthService authService = AuthService();
  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
      return const SizedBox();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Hauptbildschirm'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Hier werden die Hauptdaten angezeigt',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          Container(
            width: 250,
            color: Colors.grey[200],
            child: Column(
              children: [
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfileScreen(user: user)),
                    );
                  },
                  child: Text('Profil bearbeiten'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await authService.signOut();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text('Abmelden'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}