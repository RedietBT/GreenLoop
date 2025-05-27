import 'package:flutter/material.dart';
import 'package:greenloop/src/auth/preseniation/widgets/register_for_buseness_body.dart';

class RegisterForBussinessPage extends StatelessWidget {
  static const String routeName = '/registerForBussiness';

  final String userType;

  const RegisterForBussinessPage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
     final String role = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text("Register as $userType")),
      body: Padding(
        padding: const EdgeInsets.all(24.0), 
        child: RegisterForBussinessPageBody(role: role), 
        ),
    );
  }
}
