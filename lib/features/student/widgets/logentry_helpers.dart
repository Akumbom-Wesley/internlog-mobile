import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

const String _baseUrl = 'http://10.140.91.152:8000';

Map<String, dynamic> parseEntryResponse(dynamic response) {
  if (response is Response) {
    final responseData = response.data;
    if (responseData is Map<String, dynamic>) {
      return responseData;
    } else if (responseData is List<dynamic> && responseData.isNotEmpty) {
      if (responseData[0] is Map<String, dynamic>) {
        return responseData[0] as Map<String, dynamic>;
      }
      throw Exception('Unexpected response format: list contains non-Map item');
    }
    throw Exception('Unexpected response format: expected Map or non-empty List');
  } else if (response is Map<String, dynamic>) {
    return response;
  } else if (response is List<dynamic> && response.isNotEmpty) {
    if (response[0] is Map<String, dynamic>) {
      return response[0] as Map<String, dynamic>;
    }
    throw Exception('Unexpected response format: list contains non-Map item');
  }
  throw Exception('Unexpected response format: expected Map or non-empty List');
}

String formatDate(String? dateTimeString) {
  if (dateTimeString == null || dateTimeString.isEmpty) {
    return 'Date not available';
  }
  try {
    final dt = DateTime.parse(dateTimeString);
    return DateFormat('dd MMM, yyyy').format(dt);
  } catch (_) {
    return dateTimeString;
  }
}

String buildImageUrl(String rawPath) {
  if (rawPath.startsWith('http')) return rawPath;

  // Remove any leading slash to normalize the path
  String normalizedPath = rawPath.startsWith('/')
      ? rawPath.substring(1)
      : rawPath;

  // Always construct the full URL consistently
  return '$_baseUrl/$normalizedPath';
}