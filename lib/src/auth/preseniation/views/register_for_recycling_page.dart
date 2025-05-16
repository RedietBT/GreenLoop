import 'package:flutter/material.dart';
import 'package:greenloop/src/auth/preseniation/widgets/register_for_recycling_body.dart';

class RegisterForRecyclingPage extends StatelessWidget {
  static const routeName = '/register-recycling';

 final String userType;

  const RegisterForRecyclingPage({
    super.key,
    required this.userType,
    });

  @override
  Widget build(BuildContext context) {
    final String role = ModalRoute.of(context)!.settings.arguments as String;

      return Scaffold(
        appBar: AppBar(title: Text("Register as $userType")),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: RegisterForRecyclingBody(role: role),
        ),
      );
  }
}