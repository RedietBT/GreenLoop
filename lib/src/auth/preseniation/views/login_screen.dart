import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/preseniation/cubit/login_cubit.dart';
import 'package:greenloop/src/auth/preseniation/widgets/login_body.dart';
import 'package:greenloop/core/services/injection_container.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child:  Scaffold(
        appBar: AppBar(),
        body: LoginBody(),
      ),
    );
  }
}
