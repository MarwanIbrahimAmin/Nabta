import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/soil_analysis_response.dart';

/// API service for soil report analysis via FastAPI.
class ApiService {
  ApiService._();

  /// Base URL for the FastAPI backend.
  ///
  /// For Android emulator this typically points to `10.0.2.2`.
  static const String _baseUrl = 'http://10.0.2.2:8000';

  /// Analyzes a soil report image using the backend API.
  ///
  /// Sends a multipart/form-data request with:
  /// - `image` (required file)
  /// - `plant_name` (optional string)
  /// - `area` (optional string)
  /// - `previous_crop` (optional string)
  ///
  /// Returns a structured [SoilAnalysisResponse] on success.
  /// Throws [ApiException] for network, timeout, or server/JSON errors.
  static Future<SoilAnalysisResponse> analyzeSoilReport({
    required File imageFile,
    String? plantName,
    String? area,
    String? previousCrop,
  }) async {
    final uri = Uri.parse('$_baseUrl/analyze');
    final request = http.MultipartRequest('POST', uri);

    // Only send optional fields when they contain non-empty values.
    if (plantName != null && plantName.trim().isNotEmpty) {
      request.fields['plant_name'] = plantName.trim();
    }
    if (area != null && area.trim().isNotEmpty) {
      request.fields['area'] = area.trim();
    }
    if (previousCrop != null && previousCrop.trim().isNotEmpty) {
      request.fields['previous_crop'] = previousCrop.trim();
    }

    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: imageFile.path.split(Platform.pathSeparator).last,
    );
    request.files.add(multipartFile);

    try {
      http.StreamedResponse streamedResponse;
      try {
        streamedResponse = await request.send().timeout(
              const Duration(seconds: 60),
            );
      } on TimeoutException {
        throw ApiException('انتهت مهلة الاتصال بالخادم. يرجى المحاولة مرة أخرى.');
      }

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          'حدث خطأ في الخادم (${response.statusCode}). يرجى المحاولة لاحقًا.',
        );
      }

      Map<String, dynamic> json;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw const FormatException('Response is not a JSON object');
        }
        json = decoded;
      } on FormatException {
        throw ApiException(
          'استجابة غير متوقعة من الخادم. يرجى المحاولة لاحقًا.',
        );
      }

      try {
        return SoilAnalysisResponse.fromJson(json);
      } on FormatException {
        throw ApiException(
          'استجابة ناقصة أو غير صالحة من الخادم. يرجى المحاولة لاحقًا.',
        );
      }
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(
        'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة والمحاولة مرة أخرى.',
      );
    } catch (_) {
      // Hide internal error details from the user but keep message friendly.
      throw ApiException('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.');
    }
  }
}

/// Exception for API errors.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => 'ApiException: $message';
}
