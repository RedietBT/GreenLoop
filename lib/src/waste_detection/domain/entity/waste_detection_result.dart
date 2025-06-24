import 'package:equatable/equatable.dart';

class WasteDetectionResult extends Equatable {
  final String wasteType;
  final double confidence;
  final String sortingInstructions;
  final String incentive;
  final List<double> boundingBox;

  const WasteDetectionResult({
    required this.wasteType,
    required this.confidence,
    required this.sortingInstructions,
    required this.incentive,
    required this.boundingBox,
  });

  @override
  List<Object> get props => [wasteType, confidence, sortingInstructions, incentive, boundingBox];

  WasteDetectionResult copyWith({
    String? wasteType,
    double? confidence,
    String? sortingInstructions,
    String? incentive,
    List<double>? boundingBox,
  }) {
    return WasteDetectionResult(
      wasteType: wasteType ?? this.wasteType,
      confidence: confidence ?? this.confidence,
      sortingInstructions: sortingInstructions ?? this.sortingInstructions,
      incentive: incentive ?? this.incentive,
      boundingBox: boundingBox ?? this.boundingBox,
    );
  }
} 