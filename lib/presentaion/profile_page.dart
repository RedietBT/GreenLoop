import 'package:flutter/material.dart';
import 'package:greenloop/application/Service/auth_service.dart';
import 'package:greenloop/presentaion/login_page.dart';
import 'package:greenloop/application/infrastructure/auth/supabase_auth_repository.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService(SupabaseAuthRepository());
    final email = authService.getCurrentUserEmail();

    void logout() async {
      await authService.signOut();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Logged in as:", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(email ?? "No email found"),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: logout, child: const Text("Logout")),
          ],
        ),
      ),
    );
  }
}
