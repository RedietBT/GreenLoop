import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/on_boarding/presentation/views/on_bording_screan.dart';
import 'package:greenloop/core/commen/views/page_under_constraction.dart';
import 'package:greenloop/core/services/injection_container.dart';
import 'package:greenloop/src/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:greenloop/src/auth/preseniation/views/login_screen.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_as_cubit.dart';
import 'package:greenloop/src/auth/preseniation/views/register_as_page.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_individual_cubit.dart';
import 'package:greenloop/src/auth/preseniation/views/register_for_individual_page.dart';
import 'package:greenloop/src/auth/preseniation/cubit/register_for_recycling_cubit.dart';
import 'package:greenloop/src/auth/preseniation/views/register_for_recycling_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case OnBordingScrean.routeName:
      return _pageBuilder(
        (_) => BlocProvider(
          create: (_) => sl<OnBoardingCubit>(),
          child: const OnBordingScrean(),
        ),
        settings: settings,
      );

    case LoginScreen.routeName:
      return _pageBuilder(
        (_) => const LoginScreen(),
        settings: settings,
      );

    case RegisterAsPage.routeName:
      return _pageBuilder(
        (_) => BlocProvider(
          create: (_) => sl<RegisterAsCubit>(),
          child: const RegisterAsPage(),
        ),
        settings: settings,
      );

    case RegisterForIndividualPage.routeName:
      final userType = settings.arguments as String? ?? 'Individual / Household';
      return _pageBuilder(
        (_) => BlocProvider(
          create: (_) => sl<RegisterForIndividualCubit>(),
          child: RegisterForIndividualPage(userType: userType),
        ),
        settings: settings,
      );
      case RegisterForRecyclingPage.routeName:
  return _pageBuilder(
    (_) => BlocProvider(
      create: (_) => sl<RegisterForRecyclingCubit>(),
      child: const RegisterForRecyclingPage(),
    ),
    settings: settings,
  );

    default:
      return CupertinoPageRoute(
        builder: (_) => const PageUnderConstraction(),
        settings: settings,
      );
  }
}

PageRouteBuilder<dynamic> _pageBuilder(
  Widget Function(BuildContext) page, {
  required RouteSettings settings,
}) {
  return PageRouteBuilder(
    settings: settings,
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: animation,
      child: child,
    ),
    pageBuilder: (context, animation, secondaryAnimation) => page(context),
  );
}
