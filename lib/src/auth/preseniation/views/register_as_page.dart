import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_as_cubit.dart';
import 'package:greenloop/src/auth/preseniation/widgets/register_as_body_widget.dart';

class RegisterAsPage extends StatelessWidget {
  static const String routeName = '/registerAs'; // Define route name

  const RegisterAsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterAsCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Sign Up As")),
        body: const RegisterAsPageBody(), // Use the new body widget here
      ),
    );
  }
}
