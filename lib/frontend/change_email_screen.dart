import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangeEmailScreen extends StatelessWidget {
  final dynamic user;
  ChangeEmailScreen({Key? key, required this.user}) : super(key: key);

  final TextEditingController currentEmailController = TextEditingController();
  final TextEditingController newEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Mail ändern'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: currentEmailController,
              decoration: InputDecoration(
                labelText: 'Aktuelle E-Mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newEmailController,
              decoration: InputDecoration(
                labelText: 'Neue E-Mail',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final currentEmail = currentEmailController.text.trim();
                final newEmail = newEmailController.text.trim();

                if (currentEmail.isEmpty || newEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitte beide E-Mail-Adressen eingeben'),
                    ),
                  );
                  return;
                }

                try {
                  await FirebaseAuth.instance.currentUser
                      ?.updateEmail(newEmail);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('E-Mail erfolgreich geändert!'),
                    ),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Fehler: $e')),
                  );
                }
              },
              child: const Text('E-Mail aktualisieren'),
            ),
          ],
        ),
      ),
    );
  }
}
