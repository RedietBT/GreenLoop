import 'package:flutter/material.dart';
import 'package:greenloop/src/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnBordingScrean extends StatelessWidget {
  const OnBordingScrean({super.key});

static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnBoardingCubit, OnBoardingState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      child: Container(),
    );
  }
}