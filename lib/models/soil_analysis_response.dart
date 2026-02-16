import 'package:flutter/foundation.dart';

/// Structured result returned from the soil analysis backend.
///
/// The FastAPI service returns a JSON object with exactly three keys:
/// - `diagnosis`
/// - `recommendations`
/// - `smart_insights`
///
/// All fields are treated as strings for simplicity and robustness, and
/// any non-string JSON values will be converted to `String` via `toString()`.
@immutable
class SoilAnalysisResponse {
  const SoilAnalysisResponse({
    required this.diagnosis,
    required this.recommendations,
    required this.smartInsights,
  });

  final String diagnosis;
  final String recommendations;
  final String smartInsights;

  factory SoilAnalysisResponse.fromJson(Map<String, dynamic> json) {
    final diagnosis = json['diagnosis'];
    final recommendations = json['recommendations'];
    final smartInsights = json['smart_insights'];

    if (diagnosis == null || recommendations == null || smartInsights == null) {
      throw const FormatException('Missing keys in soil analysis response.');
    }

    return SoilAnalysisResponse(
      diagnosis: diagnosis.toString(),
      recommendations: recommendations.toString(),
      smartInsights: smartInsights.toString(),
    );
  }
}

