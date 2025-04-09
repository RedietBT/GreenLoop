import 'package:flutter/material.dart';
import 'package:greenloop/application/auth/auth_service.dart';
import 'package:greenloop/application/auth/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final authService = AuthService();
  final  _emailController = TextEditingController();
  final  _passwordController = TextEditingController();

  void login()async{
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    try {
      await authService.siginInWithEmailAndPassword(email, password);
      // Navigate to the next page after successful login
    } catch (e) {
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    }
    } finally {
      _emailController.clear();
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const RegisterPage())),
         child: Center(
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Text("Don't have an account? Sigin up"),
           ),
         )),
          ],
        ),
      ),
    );
  }}