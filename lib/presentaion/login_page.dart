import 'package:flutter/material.dart';
import 'package:greenloop/application/Service/auth_service.dart';
import 'package:greenloop/presentaion/profile_page.dart';
import 'package:greenloop/presentaion/register_as_page.dart';
import 'package:greenloop/application/infrastructure/auth/supabase_auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService(SupabaseAuthRepository());

  void _login() async {
    try {
      await _authService.siginInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text("Login")),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterAsPage()),
              ),
              child: const Text("Don't have an account? Register here."),
            ),
          ],
        ),
      ),
    );
  }
}
