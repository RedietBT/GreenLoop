import 'package:flutter/material.dart';
import 'package:greenloop/src/auth/preseniation/widgets/register_for_recycling_body.dart';

class RegisterForRecyclingPage extends StatelessWidget {
  static const routeName = '/register-recycling';

 

  const RegisterForRecyclingPage({super.key,});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text("Register Recycling Center")),
        body: const RegisterForRecyclingBody(),
      );
  }
}