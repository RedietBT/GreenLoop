import 'package:flutter/material.dart';
import 'package:greenloop/application/auth/auth_service.dart';
import 'package:greenloop/presentaion/login_page.dart';
import 'package:greenloop/infrastructure/auth/supabase_auth_repository.dart';

class RegisterPageForRecycling extends StatefulWidget {
  const RegisterPageForRecycling({super.key});

  @override
  State<RegisterPageForRecycling> createState() => _RegisterPageForRecycling();
}

class _RegisterPageForRecycling extends State<RegisterPageForRecycling> {
  final _authService = AuthService(SupabaseAuthRepository());

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _centerName = TextEditingController();
  final _contactInfo = TextEditingController();

  Map<String, dynamic>? _selectedRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await _authService.getRoles();

      // Automatically select the last role (e.g., "Recycling Center")
      final recyclingCenterRole = roles.firstWhere(
        (role) => role['id'] == 'USER102',
        orElse: () => <String, dynamic>{},
        );

      setState(() {
        _selectedRole = recyclingCenterRole;
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
      final centerName = _centerName.text.trim();
      final contactInfo = _contactInfo.text.trim();

      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Role not found. Please try again later.")),
        );
        return;
      }

      final roleId = _selectedRole!['id'];

      final response = await _authService.sigUpInWithEmailAndPassword(
        email,
        password,
        centerName,
        contactInfo,
        roleId,
      );

      final userId = response.user?.id;
      if (userId != null) {
        await _authService.insertIntoRecyclinTable(
          id: userId,
          centerName: centerName,
          contactInfo: contactInfo,
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
      appBar: AppBar(title: const Text("Register Recycling Center")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: _centerName,
                      decoration: const InputDecoration(labelText: "Recycling Center Name"),
                    ),
                    TextField(
                      controller: _contactInfo,
                      decoration: const InputDecoration(labelText: "Contact Information"),
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
                    const SizedBox(height: 20),
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
