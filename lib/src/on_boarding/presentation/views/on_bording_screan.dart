import 'package:flutter/material.dart';
import 'package:greenloop/core/commen/views/loading_view.dart';
import 'package:greenloop/src/on_boarding/presentation/cubit/on_boarding_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/commen/widgets/gradient_background.dart';
import 'package:greenloop/core/res/image.dart';
import 'package:greenloop/src/on_boarding/presentation/widgets/on_boarding_body.dart';
import 'package:greenloop/src/on_boarding/domain/entity/page_containt.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBordingScrean extends StatefulWidget {
  const OnBordingScrean({super.key});

static const String routeName = '/';

  @override
  State<OnBordingScrean> createState() => _OnBordingScreanState();
}

class _OnBordingScreanState extends State<OnBordingScrean> {

  final pageController  = PageController();
  
  @override
  void initState() {
    super.initState();
    context.read<OnBoardingCubit>().checkIfUserisFirstTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GradientBackground(
        image: MediaRes.onBoarding,
        child: BlocConsumer<OnBoardingCubit, OnBoardingState>(
          listener: (context, state) {
        
            if (state is OnBoardingStaus && !state.isFirstTimeUser) {
              Navigator.pushReplacementNamed(context, '/login');
            }else if (state is UserCashed) {
                Navigator.pushReplacementNamed(context, '/registerAs');
              } 
          },
            builder: (context, state) {
              if (state is CheckIfUserisFirstTimerState || state is CasheFirstTimer) {
                return const LoadingView();
            } 
            return Stack(
              children: [
                PageView(
                  controller: pageController,
                  children: const [
                    OnBoardingBody(pageContaint: PageContaint.first()),
                    OnBoardingBody(pageContaint: PageContaint.second()),
                    OnBoardingBody(pageContaint: PageContaint.third()),
                  ],
                ),
              Align(
                alignment: const Alignment(0.0, 0.04),
                child: SmoothPageIndicator(
                  controller: pageController,
                  count: 3,
                  onDotClicked: (index) {
                    pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                  },
                  effect: WormEffect(
                    activeDotColor: Theme.of(context).colorScheme.primary,
                    dotColor: Colors.white,
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 40.0,
                  ),
                ),
              )
              ],
            );
            }
        ),
      ),
    );
  }
}