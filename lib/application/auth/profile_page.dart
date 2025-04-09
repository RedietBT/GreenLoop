import 'package:flutter/material.dart';
import 'package:greenloop/application/auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final authService = AuthService();

  void logout() async {
    try {
      await authService.signOut();
      // Optionally, navigate to the login page or show a message
    } catch (e) {
      // Handle error if needed
      debugPrint('Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    final currentEmail = authService.getCurrentUserEmail();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to your profile!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: logout,
              child: const Text('Sign Out'),
            ),
            Text(
              'Current Email: $currentEmail',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}