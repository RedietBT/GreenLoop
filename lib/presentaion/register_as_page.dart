import 'package:flutter/material.dart';
import 'package:greenloop/presentaion/register_page_for_individual_users.dart';
import 'package:greenloop/presentaion/registeration_page_for_recycling_centers.dart';

class RegisterAsPage extends StatelessWidget {
  const RegisterAsPage({super.key});

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up As")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _navigateTo(
                  context,
                  const RegisterPage(userType: 'Individual / Household'),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Individual / Household"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _navigateTo(context, const RegisterPageForRecycling());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Recycling Center"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _navigateTo(
                  context,
                  const RegisterPage(userType: 'Business'),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Business"),
            ),
          ],
        ),
      ),
    );
  }
}
