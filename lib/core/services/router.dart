import 'package:flutter/cupertino.dart';
import 'package:greenloop/src/on_boarding/presentation/views/on_bording_screan.dart';
import 'package:greenloop/core/commen/views/page_under_constraction.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case OnBordingScrean.routeName:
      return _pageBuilder((_) => const OnBordingScrean(), 
      settings: settings);
    default:
      return CupertinoPageRoute(
        builder: (_) => const PageUnderConstraction(),
        settings: settings,
      );
  } 
}

PageRouteBuilder<dynamic> _pageBuilder(
  Widget Function(BuildContext) page,
  {required RouteSettings settings}) {
    return PageRouteBuilder(
      settings: settings,
      transitionsBuilder: (_, animation, _, chiled) => FadeTransition(
        opacity: animation,
        child: chiled,
      ),
      pageBuilder: (context, animation, secondaryAnimation) => page(context),
      );
  }
