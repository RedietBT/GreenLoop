import 'package:flutter/material.dart';
import 'package:greenloop/core/commen/widgets/gradient_background.dart';
import 'package:greenloop/core/res/image.dart';

class PageUnderConstraction extends StatelessWidget {
  const PageUnderConstraction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        image: MediaRes.constraction,
        child: Center(
            child: Image.asset(MediaRes.constraction),
        ),
      ),
    );
  }
}