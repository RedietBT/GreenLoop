import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/core/extentions/context_extention.dart';
import 'package:greenloop/src/on_boarding/domain/entity/page_containt.dart';
import 'package:greenloop/core/res/colors.dart';
import 'package:greenloop/src/on_boarding/presentation/cubit/on_boarding_cubit.dart';


class OnBoardingBody extends StatelessWidget {
  const OnBoardingBody({
    required this.pageContaint,
    super.key, 
     });

  final PageContaint pageContaint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(pageContaint.image, height: context.height * .4),
       SizedBox(height: context.height * .03),
       Padding(padding: EdgeInsets.all(20). copyWith(bottom: 0),
       child: Column(
        children: [
          Text(
            pageContaint.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              )
              ),
              SizedBox(height: context.height * .02,),
              Text(
                pageContaint.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                  ),
                ),
                SizedBox(height: context.height * .02,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: AppColors.textTertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50, 
                      vertical: 17),
                  ),
                  onPressed: ()  {
                    context.read<OnBoardingCubit>().casheFirstTimeUser();
                  }, 
                  child: const Text("Get Started",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
       ),
       ),
      ]
    );
  }
}