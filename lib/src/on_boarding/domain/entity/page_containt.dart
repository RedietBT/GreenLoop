import 'package:equatable/equatable.dart';
import 'package:greenloop/core/res/image.dart';

class PageContaint extends Equatable{
  const PageContaint({
    required this.image,
    required this.title,
    required this.description,
  });

  const PageContaint.first(): this(
    image: MediaRes.onBoarding1,
    title: 'Welcome to GreenLoop',
    description: 'Your one-stop solution for all your green needs.',
  );
  const PageContaint.second(): this(
    image: MediaRes.onBoarding2,
    title: 'Explore Our Features',
    description: 'Discover a wide range of eco-friendly products and services.',
  );
  const PageContaint.third(): this(
    image: MediaRes.onBoarding3,
    title: 'Join the Green Revolution',
    description: 'Be a part of the change for a sustainable future.',
  );

  final String image;
  final String title;
  final String description;

  @override
  List<Object?> get props => [image, title, description];
}