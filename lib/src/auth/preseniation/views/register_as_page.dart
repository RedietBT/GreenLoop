import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_as_cubit.dart';
import 'package:greenloop/src/auth/preseniation/widgets/register_as_body_widget.dart';

class RegisterAsPage extends StatelessWidget {
  static const String routeName = '/registerAs'; // Define route name

  const RegisterAsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color appBarBg = isDark ? const Color(0xFF181C1B) : Colors.transparent;
    return BlocProvider(
      create: (_) => RegisterAsCubit(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: appBarBg,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: RegisterAsPageBody(
              cardElevation: isDark ? 24 : 32,
            ),
          ),
        ),
      ),
    );
  }
}
