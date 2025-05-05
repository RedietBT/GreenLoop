import 'package:flutter/material.dart';
import 'package:greenloop/application/Service/auth_service.dart';
import 'package:greenloop/presentaion/login_page.dart';
import 'package:greenloop/application/infrastructure/auth/supabase_auth_repository.dart';

class RegisterPage extends StatefulWidget {
  final String userType; // Accepts either 'Individual / Household' or 'Business'

  const RegisterPage({super.key, required this.userType});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _authService = AuthService(SupabaseAuthRepository());

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  List<Map<String, dynamic>> _roles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await _authService.getRoles();
      setState(() {
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load roles: ${e.toString()}")),
      );
    }
  }

  void _register() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      // Get role ID based on userType
      final matchedRole = _roles.firstWhere(
        (role) =>
            (role['role'] ?? role['name']) == widget.userType,
        orElse: () => {},
      );

      if (matchedRole.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Role not found.")),
        );
        return;
      }

      final roleId = matchedRole['id'];

      final response = await _authService.sigUpInWithEmailAndPassword(
        email,
        password,
        firstName,
        lastName,
        roleId,
      );

      final userId = response.user?.id;
      if (userId != null) {
        await _authService.insertUserProfile(
          id: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
          role: roleId,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: "First Name"),
                    ),
                    TextField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: "Last Name"),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _register,
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
